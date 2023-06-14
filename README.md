
# Table of Contents

1.  [M365 Calendar export](#org51a3edb)
2.  [what it does](#orge0090b1)
    1.  [compiles events](#org27a90af)
    2.  [user curated agenda](#org3ce7e1d)
    3.  [most important tasks](#orgb1f1155)
    4.  [export](#org4d84ba9)
3.  [why it&rsquo;s useful](#org69b307d)
    1.  [intentionality](#org58b747b)
4.  [how to use it](#org44e916c)
    1.  [prerequisites](#org90f2927)
        1.  [microsoft graph api cli](#orge2a84f4)
        2.  [pandoc](#orgd472bbd)
        3.  [exporting](#orgdcbecf3)
    2.  [running the script](#orga2f2aa0)
        1.  [configuration](#org554714b)
        2.  [what it will show you](#orgd6a35e6)
        3.  [what it will ask you](#orgef7c552)
    3.  [print it out (optional)](#org8d90c16)
5.  [script](#orge04ed76)
    1.  [msgraph-cli](#orgcce0208)
        1.  [configuration](#org8f8e6f2)
        2.  [logging in](#org2ba4a8b)
        3.  [logging out](#orga6cdc3f)
        4.  [getting calendar events for the day](#org3ead3a6)
    2.  [pandoc](#org97f3de9)
        1.  [installation](#org3cbf925)
        2.  [converting txt to docx](#org373df60)



<a id="org51a3edb"></a>

# M365 Calendar export


<a id="orge0090b1"></a>

# what it does


<a id="org27a90af"></a>

## compiles events

-   this zsh script uses the microsoft graph api cli to compile all events from a user&rsquo;s m365 calendar for the current date.


<a id="org3ce7e1d"></a>

## user curated agenda

-   the user is able to choose specific events from their m365 calendar to appear in their agenda view or even create their own


<a id="orgb1f1155"></a>

## most important tasks

-   the user is also able to delegate either an event from their m365 calendar or create their own event that is considered &ldquo;most important&rdquo;


<a id="org4d84ba9"></a>

## export

-   the user can export their daily agenda to different file types including:
    -   .txt
    -   docx (with/without reference template)


<a id="org69b307d"></a>

# why it&rsquo;s useful


<a id="org58b747b"></a>

## intentionality

-   it&rsquo;s easy to live REACTIVELY, reacting to life&rsquo;s events as they appear, which can lead to a feeling of less control. this tool will help individuals live more PROACTIVELY, not letting the calendar dictate life decisions, but rather help the user be INTENTIONAL with their daily tasks.


<a id="org44e916c"></a>

# how to use it


<a id="org90f2927"></a>

## prerequisites


<a id="orge2a84f4"></a>

### microsoft graph api cli

1.  how it&rsquo;s used

    -   more information on use can be found in [msgraph-cli](#orge04ed76)

2.  installation

    -   github link: <https://github.com/microsoftgraph/msgraph-cli>

3.  configuration

    -   make sure you know the path to the folder that you download before running


<a id="orgd472bbd"></a>

### pandoc

1.  what is it

    -   free software document converter

2.  installation

        # installs pandoc
        brew install pandoc


<a id="orgdcbecf3"></a>

### exporting

1.  docx as a template

    -   doc template must be in docx format


<a id="orga2f2aa0"></a>

## running the script


<a id="org554714b"></a>

### configuration

-   to make the script executable, run:
    
        chmod +x /path/to/export_calendar.sh
-   to run the script, run:
    
        ./path/to/export_calendar.sh


<a id="orgd6a35e6"></a>

### what it will show you

-   all events from m365 calendar for the current date
-   a tailored &ldquo;daily agenda&rdquo; along with important tasks all curated by you


<a id="orgef7c552"></a>

### what it will ask you

-   path to the msgraph-cli folder
-   m365 username
-   m365 authentication (all done by microsoft)
-   what events you&rsquo;d like in your daily agenda
-   what events would you like to make most important
-   multiple export options (plaintext, docx, etc)
    -   path of export
    -   path of docx reference template (if necessary)


<a id="org8d90c16"></a>

## print it out (optional)

-   small piece of paper/card to remind yourself about your intentional choices will help you feel more control throughout the day


<a id="orge04ed76"></a>

# script

-   this section discusses specific details of the script regarding how a user is authenticated through m365 and how their overall events are extracted
-   pandoc export is also explored in this section


<a id="orgcce0208"></a>

## msgraph-cli


<a id="org8f8e6f2"></a>

### configuration

    # exporting the path of msgraph-cli to be able to use it
    export PATH=$PATH:[path/to/msgraph-cli/]


<a id="org2ba4a8b"></a>

### logging in

    # logs into microsoft graph api with read/write permissions for calendar events
    mgc login --scopes Calendars.ReadWrite --scopes Calendars.ReadWrite.shared --scopes User.ReadWrite

-   this allows user to have read/write permissions to access events in their m365 calendar
-   authentication is done with the device and the code will be printed when running the script


<a id="orga6cdc3f"></a>

### logging out

    # logs out of microsoft graph api
    mgc logout


<a id="org3ead3a6"></a>

### getting calendar events for the day

1.  overall list

        # lists all events filtered by today's date by ascending order of time
        mgc users calendar events list --user-id person@domain.com --filter "start/dateTime ge $currentDate and start/dateTime lt $tomorrowDate" --orderby "start/dateTime"
    
    -   this lists all events for today for the specified user
    -   this list is also ordered by time

2.  querying list properties

    1.  subject
    
            # queries the subject for a list of events filtered by today's date by ascending order of time
            mgc users calendar events list --user-id person@domain.com --filter "start/dateTime get $currentDate and start/dateTime lt $tomorrowDate" --orderby "start/dateTime" --query "value[$i].subject"
    
    2.  time
    
            # queries the time for a list of events filtered by today's date by ascending order of time
            mgc users calendar events list --user-id person@domain.com --filter "start/dateTime get $currentDate and start/dateTime lt $tomorrowDate" --orderby "start/dateTime" --query "value[$i].start.dateTime"


<a id="org97f3de9"></a>

## pandoc


<a id="org3cbf925"></a>

### installation

    # install pandoc
    brew install pandoc


<a id="org373df60"></a>

### converting txt to docx

1.  with reference docx

        # pandoc export to docx with a reference docx
        sed -e 's/$/  \n/' "$TEMP_TEXT_FILE" | pandoc --to=docx --reference-doc="$TEMPLATE_PATH" --wrap=preserve -o "$OUTPUT_DOCX"
    
    -   preserves indentation and line breaks
    -   &ldquo;$TEMP<sub>TEXT</sub><sub>FILE</sub>&rdquo; is a temporary .txt file that is necessary to create for pandoc to convert it into docx.  it is removed later on.
    -   &ldquo;$OUTPUT<sub>DOCX</sub>&rdquo; is the path that the user will input to export their agenda
    -   &ldquo;$TEMPLATE<sub>PATH</sub>&rdquo; is the path of your reference doc template (must be docx!)

2.  without reference docx

        # pandoc export to normal docx
        sed -e 's/$/  \n/' "$TEMP_TEXT_FILE" | pandoc --to=docx --wrap=preserve -o "$OUTPUT_DOCX"
    
    -   preserves indentation and line breaks

