<div style="text-align: center;">
<img src="Documentation/Images/Icon_Graphs_512.png" width="250"/>
</div>

# Graphs

Graphs is a data management tool that allows you to store your raw data files in a text formate (CSV, tab delimited, etc.) and then have those files automatically parsed and graphed on demand.  The goal is to simplify 2D data organization and visualization.  I wrote the precursor to Graphs (then called GraphBase) during my Ph.D. to help manage the data I was collecting as part of his disseration.  I was becoming overwhelmed by the hundreds of data files I was collecting every week; each file collected on the instrument would be analyzed using Excel or Matlab, then graphed in Datagraph, and then exported as a .tiff file.  Through this process, each individual data file quickly became three or four separate files and comparing the experiments was also more work than it felt like it should be.  Inspired by the Papers application on OS X (now macOS), I wrote an application that would organize and display data the way that Papers organizes and displays journal articles.  The original GraphBase application was written in Objective-C and provided an easy way to both create a parser template for parsing text files into columns of data and also import DataGraph files to use as a templates for graphing the data.

In 2014, Connor Barnes used GraphBase as a starting to point write version 1 of Graphs with the goal of transitioning from Objective-C to Apple's' Swift programming language (which as relatively new at the time).  Version 2 is another rewrite of Graphs to transition away from the original AppKit and CoreData to the modern SwiftUI and SwiftData respectively.  I plan to continue evolving this application.  The next plan improvements are: migrating to Swift 6.2 to help fix and future proof against data-race bugs followed by adding caching for improved responsiveness.  Long term, we hope to add support for data analysis by extracting variables from the DataGraph file and eventually incorporate third-party analysis using Swift' new SubProcess APIs.

The graphing component of the application used DataGraph's available framework (http://www.visualdatatools.com/DataGraph/Framework/) and is a key component of this approach because it allows users to create rich, complex 2D graphs using DataGraph (which has an amazingly well-designed UI) and then use their datagraph files as templates for visualizing their data in GraphBase.  Essentially, it allows you to graph your data once and then reuse that graph as a template for visuallizing rest of your data.  Since scientists and engineers collect lots of different types of data with different visuallization needs, Graphs allows you to import and manage as many different graph templates as you need and includes an easy-to-use UI for assigning those templates to sets of folders and individual files as needed.  By default, sub-folders inheret the default Parser and Graph templates from their Parent folder, but this can always be overwritten.  

During my Ph.D. I used the original GraphBase to organize thousands of data files and noticed that, instead of just looking at the "good" data, I was looking at all of my data.  As a result, I noticed trends or interesting outliers that I probably wouldn't have.  I hope Graphs helps you manage your data and supports your research the way it supported mine.


##Requirements

- macOS 26+
- DataGraph License


## Restrictions
Currently, the DataGraph framework is only available as a pre-compiled 32-bit framework.  As a result, Graphs runs under Rossetta 2.

##Installation
Compiled binarys are stored in a .zip file in each release build.  To install graphs, download and un-zip the .zip file.  Next, drag the *Graphs.app* file to your *Applications* Folder. While Graphs is a signed application, it isn't Sandboxed, so the first time you run Graphs, you will need to go into *System Settings → Privacy and Security → Open Anyway*. Note, the *Open Anway* dialog can change from macOS verison to version.  It is typically located towards the bottom of the *Privacy and Security* panel.


Please note that you will need a DataGraph license to create the graph templates used by the DataGraph framework underlying Graphs.  DataGraph (http://www.visualdatatools.com/DataGraph/) is an amazing 2D graphing application that is work trying out even if you don't use Graphs.  

##Compiling

To compile Graphs yourself:

- Download the DataGraph framework: http://www.visualdatatools.com/DataGraph/Framework/
- Open the downloaded .dmg folder and copy the *DataGraph.frameworks* folder to: *Macintosh HD/Library/Frameworks/*
- Download the Graphs source code and open the project
- Update the signing information
- Double-check that the DataGraph framework is pointing to the framework you installed ealier
- Double-check that the Project and Target settings are appropriated for your system.  The project is currently targetting macOS 26 and above.

# Usage
To use Graphs, first you create a graph template in DataGraph.  Format the graph the way you want it to look and make sure that the Data Columns are in the same order as the columns in your data.  Note, the data columns that you are overwriting must be the first set of columns and cannot be located inside a group.  Next, you  add your "Graph Template" to Graphs using either the Graph Template Inspector on the right side of Graphs or using using the "+" sign on the bottom left of the application or using the menu bar (File → Import).  You can also drag-and-drop the file onto a folder in the Source List (left column).  Once you add a Graph Template, you can assign it to be the default Graph Template for a folder and any sub-folders using the Folder Inspector.

The second step is to make a Parser using the Parser Inspector.  It might be helpful to have an example file already in Graphs (see Step 3) because you can use the Text Inspector to see what lines your Experimental Details, Header, and Data start at.  Add a Parse Template using the + sign in the Parse Inspector's table and give the Parse Template a name.  If your data has experimental details at the top, then select the checkbox and set the starting and ending lines for this information.  If your data has a Header, select the Header checkbox, give it starting and ending line numbers, and then select the type of separator your file uses to delineate columns.  This header will be used to overwrite the columns in your Graph Template.  Lastly set the starting line of your data and the separator type.  You can select to have the Data stop at an empty line in case there is extra, non-data, at the end of your data.  Just like the Graph Template, you can use the Folder Inspector to set this Parser as the default parser for a specific folder and its sub-folders.

The third step is to add some data.  The data must be a text file (such as .csv or txt, etc).  You can add one file at a time or entire directories with sub-folders using either the "+" sign in the bottom right or drag-and-drop the file/folder into the Source List on the left.  The files and any sub-folders will imported as references into Graphs and located within the folder selected in the Source List.  At this time, files will inherit the default Graph Template and Parser of the folder they were imported into. Note: if your files aren't importing, check Graph's Settings to make sure your file's extension is on the allowed import file extension list.

At anytime, you can change the default Graph Template and Parser for a Folder, selection of multiple folders, file, or selection of files using the Folder and File Inspectors.

Now that you've got Graph Templates, Parsers, and Data, you are ready to go.  Simply navigate to your data using the Source List, select the data you are interested in viewing from the Table View in the middle and look at your data using the Graph Views below.  The selected data is parsed using the Parse Template and then graphed using the Graph Template and the DataGraph Framework.  Any changes you make to the Graph Template using DataGraph will be reflected next time you selected data that uses that graph template.  The same is true for the Parser.  As a result, you can evolve your graphs as needed without having to get it perfect the first time.


## Contributions and Comments
This project is a slow-moving "labor-of-love" for our group and intended additional features, such as USB support, are worked on sporatically based upon need, time, and our ability to deal with Apple's poor documentation.  We would love help and please e-mail me (or to reply to the relevant issue or open a new one).

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owner of this repository before making a change.

### All Code Changes Happen Through Pull Requests

1. Fork the repo and create your branch from `master`.
2. Make sure the syle of your code is consistent with that of the current one (indentation, etc.).
3. If you've changed any relevant functionalities, update the documentation.
4. Ensure the application is working correctly.
5. Issue that pull request.

### Code of Conduct

Use common sense (source: https://github.com/gasparl/possa/blob/master/CONTRIBUTING.md)

Examples:

* Be respectful of differing viewpoints and experiences
* Gracefully accept constructive criticism
* Focus on what is best for the community
* Have empathy towards other community members

Examples of unacceptable behavior by participants include:

* Trolling, insulting/derogatory comments, and personal or political attacks
* Public or private harassment
* Publishing others' private information without explicit permission
* Other conduct which could reasonably be considered inappropriate in a
  professional setting
  
 
### Reporting Issues or Problems
* Please submit an Issue if you have any problems with using or installing Graphs

## Licensing
This project is licensed under the terms of the GNU General Public License v3.0.  See License.txt for details.
