# telling user that brew pandoc is being run
echo "making sure your computer has pandoc installed to properly export your calendar..."

# ensuring user has pandoc installed
brew install pandoc

# exporting path to include the msgraph-cli
echo "what is the path to the msgraph-cli folder?"
# read user input
read MSGRAPH_PATH
# obtain absolute path from user input
eval MSGRAPH_PATH="$MSGRAPH_PATH"
# exporting path
export PATH=$PATH:"$MSGRAPH_PATH"

# initiating sign in

echo "signing in..."

# opens up authentication window
open https://microsoft.com/devicelogin

# allows user with read/write permissions for their calendar
mgc login --scopes Calendars.ReadWrite --scopes Calendars.ReadWrite.shared --scopes User.ReadWrite
echo "Enter your username:"
# read user input for username
read USERNAME
echo "login successful!"

# getting calendar events for the day

# getting current date in YYYY:MM:DD format
currentDate=$(echo \'$(date +%Y-%m-%d)\')

# getting current date in YY:WW format
currentDatePrint=$(echo $(date +%y.%U))

# getting tomorrow's date in YYYY:MM:DD format
tomorrowDate=$(echo \'$(date -v +1d +%Y-%m-%d)\')

# getting the number of events for the day
eventCount=$(mgc users calendar events list --count --user-id "$USERNAME" --filter "start/dateTime ge $currentDate and start/dateTime lt $tomorrowDate" --query '"@odata.count"')

# displaying the events for today's date
echo "events for" $currentDate

# declare an empty array to store events
events=()

# getting the time and subject of the event and printing them in order
for i in $(seq 0 $((eventCount-1))); do

    # queries the subject for a list of events filtered by today's date by ascending order of time
    value=$(mgc users calendar events list --user-id "$USERNAME" --filter "start/dateTime ge $currentDate and start/dateTime lt $tomorrowDate" --orderby "start/dateTime" --query "value[$i].subject")

    # queries the time for a list of events filtered by today's date by ascending order of time
    dateTime=$(mgc users calendar events list --user-id "$USERNAME" --filter "start/dateTime ge $currentDate and start/dateTime lt $tomorrowDate" --orderby "start/dateTime" --query "value[$i].start.dateTime")

    # converting UTA to EST by separating the hour and the minute and subtracting 4 hours
    timeOnly=${dateTime#*T}
    specificTime="4:00"

    hourOnly=${timeOnly%%:*}
    minuteOnly1=${timeOnly#*:}
    minuteOnly=${minuteOnly1%%:*}

    specificHour=${specificTime%%:*}
    specificMinute=${specificTime#*:}

    timeDifference=$(( (hourOnly - specificHour) * 60 + minuteOnly - specificMinute ))

    hours=$((timeDifference / 60))
    minutes=$((timeDifference % 60))

    # printint out correctly formatted hours and minutes
    timeDifferenceFormatted=$(printf "%02d:%02d" "$hours" "$minutes")

    # populating array with events with new time and subject
    events[$i]="$timeDifferenceFormatted $value"

done

# print the events array
for i in $(seq 0 $((eventCount-1))); do
    echo [$i] ${events[$i]}
done

# allowing user to choose what events they'd like to include in today's agenda

# declaring an array to store user chosen events
selectedEvents=()
while true; do
    echo "What events would you like to have in today's agenda?"
    echo "Choose an option:"
    echo "  - Enter the event number (0-$((eventCount-1)))"
    echo "  - Press 'a' to select all tasks"
    echo "  - Press 'i' to input your own task"
    echo "  - Press 'r' to reselect today's calendar events"
    echo "  - Press 'c' to continue"
    echo "  - Press 'q' to quit"
    read ANSWER

    # for selecting each event number
    if [[ "$ANSWER" =~ ^[0-9]{1,2}$ ]] && (( ANSWER >= 0 && ANSWER < eventCount )); then
        output=${events[$ANSWER]}
        # adds user selected event to the array
        selectedEvents+=("$output")
        echo "$output successfully added!"
    
    # for selecting all events
    elif [[ "$ANSWER" == "a" ]]; then
        # adds all events to the new array
	    selectedEvents=("${events[@]}")
	    echo "all events selected!"

    # after user is done selecting events
    elif [[ "$ANSWER" == "c" ]]; then
	    echo "Your selected events for today:"
        # formatting to sort the events by order of time in case user inputs out of order
	    IFS=$'\n' sortedEvents=($(printf "%s\n" "${selectedEvents[@]}" | sort -t '"' -k1,1))
	    for event in "${sortedEvents[@]}"; do
		    echo "- $event"
	    done

	# confirmation of selected events
        while true; do
            echo "Confirm selection? (y/n)"
            read CONFIRM

            if [[ "$CONFIRM" == "n" ]]; then
                # clears selectedEvents array and prompts user to start over
                selectedEvents=()
                echo "Selection cleared. Start over."
                break
            elif [[ "$CONFIRM" == "y" ]]; then
                # moves onto next prompt
                echo "Selection confirmed."
                break 2
            else
                echo "$CONFIRM is an invalid answer. Please enter 'y' or 'n'."
           fi
        done

    # if user wants to clear selection and start over
    elif [[ "$ANSWER" == "r" ]]; then
        # clears selectedEvents array and prompts user to start over
        selectedEvents=()
        echo "Selection cleared. Start over."

    # if user wants to quit the script
    elif [[ "$ANSWER" == "q" ]]; then
        # moves onto next part of the script
        echo "Quitting..."
        break

    # if user wants to input their own event not in the outlook calendar
    elif [[ "$ANSWER" == "i" ]]; then
        # user inputs time of their new event
        echo "Enter the time in HH:MM format:"
        read time

        # user inputs subject of their new event
        echo "Enter the subject of the event:"
        read subject

        # new event follows same format
        output="$time \"$subject\""
        selectedEvents+=("$output")
        echo "Your own task '$output' successfully added!"
    else
        echo "$ANSWER is an invalid answer."
    fi
done


# Print the events array
for i in $(seq 0 $((eventCount-1))); do
    echo [$i] ${events[$i]}
done

# declaring an array for user selected important tasks
selectedImportantTasks=()

while true; do
    echo "What would you like your most important tasks to be for today?"
    echo "Choose an option:"
    echo "  - Enter the event number (0-$((eventCount-1)))"
    echo "  - Press 'i' to input your own task"
    echo "  - Press 'r' to reselect your important tasks"
    echo "  - Press 'c' to continue"
    echo "  - Press 'q' to quit"
    read ANSWER

    # for selecting each event
    if [[ "$ANSWER" =~ ^[0-9]{1,2}$ ]] && (( ANSWER >= 0 && ANSWER < eventCount )); then
        output=${events[$ANSWER]}
        # adds user selected events to the new array
        selectedImportantTasks+=("$output")
        echo "$output successfully added!"

    # for continuing after selecting events
    elif [[ "$ANSWER" == "c" ]]; then
        echo "Your most important tasks:"

        # formatting to sort the events by order of time in case user inputs out of order
	IFS=$'\n' sortedImportantTasks=($(printf "%s\n" "${selectedImportantTasks[@]}" | sort -t '"' -k1,1))
        for task in "${sortedImportantTasks[@]}"; do
                echo "- $task"
        done
	
	# confirmation for selection
        while true; do
            echo "Confirm selection? (y/n)"
            read CONFIRM

            if [[ "$CONFIRM" == "y" ]]; then
                # moves onto next prompt in the script
                break 2  # Exit both inner and outer loop
            elif [[ "$CONFIRM" == "n" ]]; then
                # clears selectedEvents array and prompts user to start over
                selectedImportantTasks=()
                echo "Selection cleared. Start over."
                break
            else
                echo "$CONFIRM is an invalid answer. Please enter 'y' or 'n'."
            fi
        done

    # if user wants to clear selection
    elif [[ "$ANSWER" == "r" ]]; then
        # clears array and user can reselect tasks
        selectedImportantTasks=()
        echo "Selection cleared. Start over."

    # if user wants to quit
    elif [[ "$ANSWER" == "q" ]]; then
        # moves onto next part of script
        echo "Quitting..."
        break

    # if user wants to input their own important task
    elif [[ "$ANSWER" == "i" ]]; then
        # user inputs the time of the event
        echo "Enter the time in HH:MM format:"
        read time

        # user inputs the subject of the event
        echo "Enter the subject of the task:"
        read subject

        output="$time \"$subject\""
        selectedImportantTasks+=("$output")
        echo "Your own task '$output' successfully added!"
    else
        echo "$ANSWER is an invalid answer."
    fi
done

# displaying user curated agenda

# declaring strings for file output
agendaOutput=""
importantTaskOutput=""

# printing to the console the daily events as well as putting them in agendaOutput for file export
echo "your agenda for today:"
agendaOutput+="your agenda for today:"$'\n'
        for event in "${sortedEvents[@]}"; do
                echo "- $event"
		agendaOutput+="- $event"$'\n'
done

# printing to the console the most important tasks as well as putting them in importantTaskoutput for file export
echo "your most important tasks:"
importantTaskOutput+="your most important tasks:"$'\n'

IFS=$'\n' sortedImportantTasks=($(printf "%s\n" "${selectedImportantTasks[@]}" | sort -t '"' -k1,1))
        for task in "${sortedImportantTasks[@]}"; do
		
                echo "- $task"
		importantTaskOutput+="- $task"$'\n'
        done

fileOutput="$agendaOutput"$'\n'"$importantTaskOutput"

# showing export options to user

while true; do
    echo "export options:"
    echo "  - press 't' to export as plain text"
    echo "  - press 'd' to export as docx file"
    echo "  - press 'dt' to export to a docx template"
    echo "  - press 'q' to quit and sign out"
    read EXPORT_OPTION

  # if user wants to export as plain text
  if [[ "$EXPORT_OPTION" == "t" ]]; then
	echo "enter the file path to save the plain text file:"

    # taking the absolute path of what user inputs
	read FILE_PATH
	eval FILE_PATH="$FILE_PATH"

    # makes directory if directory doesn't exist
	DIRECTORY=$(dirname "$FILE_PATH")
   	mkdir -p "$DIRECTORY"

    # creates the file if file doesn't exist
	touch "$FILE_PATH"
	FILE_PATH=$(realpath -q "$FILE_PATH")

    # prints to file and overwrites everything that was there before
	printf "%s" "$fileOutput" > "$FILE_PATH"
	echo "file exported as plain text."

    # gives user option to open file
	read -p "open file? (y/n): " OPEN_FILE_OPTION
        if [[ "$OPEN_FILE_OPTION" == "y" ]]; then
            open "$FILE_PATH"  # Open the file using the default application (Linux)
        fi

  # if user wants to export as docx file
  elif [[ "$EXPORT_OPTION" == "d" ]]; then
        echo "Enter the file path to save the docx file:"

        # taking absolute path of what user inputs
        read FILE_PATH
        eval FILE_PATH="$FILE_PATH"

        # creating directory if it doesn't exist
        DIRECTORY=$(dirname "$FILE_PATH")
        mkdir -p "$DIRECTORY"

	# creating temp text file to print to in order for pandoc to convert to docx
	TEMP_TEXT_FILE="temp.txt"
	printf "%s" "$fileOutput" > "$TEMP_TEXT_FILE"

    # preserves the indentation and line breaks
	OUTPUT_DOCX="$FILE_PATH"
	sed -e 's/$/  \n/' "$TEMP_TEXT_FILE" | pandoc --to=docx --wrap=preserve -o "$OUTPUT_DOCX"

	# removing the temp text file
	rm "$TEMP_TEXT_FILE"

        echo "file exported as docx."
        # option for user to open file
	    read -p "open file? (y/n): " OPEN_FILE_OPTION
            if [[ "$OPEN_FILE_OPTION" == "y" ]]; then
                open "$FILE_PATH"  # Open the file using the default application (Linux)
            fi

  # if user wants to export to docx file with a reference docx template
   elif [[ "$EXPORT_OPTION" == "dt" ]]; then
        echo "Enter the file path to save the doc template:"

        # takes absolute path of what user inputs
        read FILE_PATH
        eval FILE_PATH="$FILE_PATH"
        DIRECTORY=$(dirname "$FILE_PATH")
        mkdir -p "$DIRECTORY"

        # takse absolute path of reference doc
	    echo "enter the file path for reference doc"
	    read TEMPLATE_PATH
	    eval TEMPLATE_PATH="$TEMPLATE_PATH"

	    # creating temp text file to print to in order for pandoc to conver to docx
	    TEMP_TEXT_FILE="temp.txt"
	    printf "%s" "$fileOutput" > "$TEMP_TEXT_FILE"

        # preserving desired indentation and line breaks
	    OUTPUT_DOCX="$FILE_PATH"
	    sed -e 's/$/  \n/' "$TEMP_TEXT_FILE" | pandoc --to=docx --reference-doc="$TEMPLATE_PATH" --wrap=preserve -o "$OUTPUT_DOCX"
	
	    # removing the temp text file
	    rm "$TEMP_TEXT_FILE"

	    echo "file exported as doc template."
	    read -p "open file? (y/n): " OPEN_FILE_OPTION
        if [[ "$OPEN_FILE_OPTION" == "y" ]]; then
            open "$FILE_PATH"  # Open the file using the default application (Linux)
        fi

  # if user wants to quit
  elif [[ "$EXPORT_OPTION" == "q" ]]; then
        echo "quitting...."
        break
  # if user clicks none of the answer choices
  else
        echo "$EXPORT_OPTION is an invalid option. Please enter 'c', 't', or 'q'."
  fi
done

# signing user out after export calendar function is ran

echo "signing out..."
mgc logout
echo "logout successful!"
