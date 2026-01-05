# Graphs
Graphs is a macOS application that simplifies data organization and visualization.  Hildreth wrote the precursor to Graphs (then called GraphBase) during his Ph.D. to help manage the data he was collecting as part of his research on Metal-assisted Chemical Etching of Silicon.  He was becoming overwhelmed by the hundreds of data files he was collecting every week, each file would have to be collected on the instrument, analized using Excel or Matlab, then graphed in Datagraph, and then exported as a .tiff file.  Each individual data file quickly became three or four separate files.  And comparing the experiments was also more work than it felt like it should be.  Inspired by the Papers and iTunes applications on OS X (now macOS), Hildreth created an application that would organize and display data the way that Papers organizes and displays journal articles.  The original GraphBase application was written in Objective-C and provided an easy way to create a parsing template to parse text files into columns of data and import a DataGraph file to use as a template for graphing the data using the available DataGaph framework (http://www.visualdatatools.com/DataGraph/Framework/).  The DataGraph framework was a key component of this approach because it allows users to create rich, complex 2D graphs using DataGraphs and extermely well-designed UI and then use their graph file as a template for visualizing their data in GraphBase.

Please note that you will need a DataGraph license to create the graph templates used by the DataGraph framework underlying Graphs.  DataGraph (http://www.visualdatatools.com/DataGraph/) is an amazing 2D graphing application that is work trying out even if you don't use Graphs.  Version 1 of Graphs was written by Connor Barnes to transition from Objective-C to Apple's' relatively new (at the time) Swift programming language.  Version 2 is a rewrite of Graphs to transitions away from the original AppKit and CoreData to the modern SwiftUI and SwiftData respectively.   Hildreth plans to continue evolving this application.  The next plan improvements are: migrating to Swift 6.2 and adding caching and background caching for improved responsiveness.  Long term, we hope to add support for data analysis by extracting variables from the DataGraph file and eventually incorporate third-party analysis using Swift' new SubProcess APIs.

# Overview
Graphs is a data management tool that allows you to store your raw data files in a text formate (CSV, tab delimited, etc.) and then have those files automatically parsed and graphed on demand.

To use Graphs, first you create a graph template in DataGraph.  Format the graph the way you want it to look and make sure that the Data Columns are in the same order as the columns in your data.  Note, the data columns that you are overwriting must be the first set of columns and cannot be located inside a group.  Next, you  add your "Graph Template" to Graphs using either the Graph Template Inspector on the right side of Graphs or using using the "+" sign on the bottom left of the applicationo or using the menu bar (File → Import).  You can also drag-and-drop the file onto a folder in the Source List (left column).  Once you add a Graph Template, you can assign it to be the default Graph Template for a folder and any sub-folders using the Folder Inspector.

The second step is to make a Paser using the Parser Inspector.  It might be helpful to have an example file already in Graphs (see Step 3) because you can use the Text Inspector to see what lines your Experimental Details, Header, and Data start at.  Add a Parse Template using the + sign in the Parse Inspector's table and give the Parse Template a name.  If your data has experimental details at the top, then select the checkbox and set the starting and ending lines for this information.  If your data has a Header, select the Header checkbox, give it starting and ending line numbers, and then select the type of separator your file uses to deliniate columns.  This header will be used to overwrite the columns in your Graph Template.  Lastly set the starting line of your data and the separator type.  You can select to have the Data stop at an empty line in case there is extra, non-data, at the end of your data.  Just like the Graph Template, you can use the Folder Inspector to set this Parser as the default parser for a specific folder and its sub-folders.

The third step is to add some data.  The data must be a text file (such as .csv or txt, etc).  You can add one file at a time or entire directories with sub-folders using either the "+" sign in the bottom right or drag-and-drop the file/folder into the Source List on the left.  The files and any sub-folders will imported as references into Graphs and located within the folder selected in the Source List.  At this time, files will inheret the default Graph Template and Parser of the folder they were imported into. Note: if your files aren't importing, check Graph's Settings to make sure your file's extension is on the allowed import file extension list.

At anytime, you can change the default Graph Template and Parser for a Folder, selection of multiple folders, file, or selection of files using the Folder and File Inspectors.

Now that you've got Graph Templates, Parsers, and Data, you are ready to go.  Simply navigate to your data using the Source List, select the data you are intersted in viewing from the Table View in the middle and look at your data using the Graph Views below.  The selected data is parsed using the Parse Template and then graphed using the Graph Template and the DataGraph Framework.  Any changes you make to the Graph Template using DataGraph will be reflected next time you selected data that uses that graph template.  The same is true for the Parser.  As a result, you can evolve your graphs as needed without having to get it perfect the first time.

![Overview of Graphs](Images/Overview.png)

![File Inspector](Images/Inspector-File.png)

![Directory Inspector](Images/Inspector-Directory.png)

![Parser Inspector](Images/Inspector-Parser.png)

![Graph Template Inspector](Images/Inspector-Graphs.png)

![Text Inspector](Images/Inspector-Text.png)

![Table Inspector](Images/Inspector-Table.png)


# Licensing
Licensed under the MIT licensing terms: https://opensource.org/licenses/MIT


