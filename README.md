# Graphs
A macOS app that manages the organization of data files and graphs them.

Licensed under the MIT licensing terms: https://opensource.org/licenses/MIT

Hildreth wrote the precursor to Graphs, then called GraphBase, during his Ph.D. to help manage the data he was collecting as part of his research on Metal-assisted Chemical Etching of Silicon.  He was becoming overwellmed by the hundreds of data files he was collecting every week and was inspired by the Papers and iTunes applications on OS X (now macOS) to create an application that managed data.  GraphBase provided an easy template to create a parser, a simple UI to organize data into hiarchical folders, and leveraged the DataGraph framework (http://www.visualdatatools.com/DataGraph/Framework/) for graphing.  DataGraph is an amazing 2D graphing application that makes it easy to create beautiful graphs.  

Graphs is a rewrite of GraphBase in Swift written by Connor that has been open sourced for use by all.  Please not that you will need a DataGraph license to create the graph templates used by the DataGraph framework underlying Graphs.  Hildreth plans to continue evolving this application through future CS Field Sessions.  The next plan improvements are: multithreading for import and parsing using the new Results type in Swift; and begin switching over to SwiftUI for the UI.  Long term, we hope to add support for data analysis and extraction.

# Overview
[Overview of Graphs](Images/Overview.png)
