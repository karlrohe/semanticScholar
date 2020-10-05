# Preliminary processing for semantic scholar open corpus data

This repo creates an adjacency matrix of *citations between journals* using data from [Semantic Scholar](https://www.semanticscholar.org/).  ![](semanticScholarLogo.png)
     
The data is [available here](http://s2-public-api-prod.us-west-2.elasticbeanstalk.com/corpus/). 

The data comes as JSON.  This repo makes it into a few different flat csv's and graphs. This code does not run on my imac with 8GB of memory, but it does run on my laptop that has 16GB of memory. Downloading the data and creating these files will likely take 200GB of storage.  

When you download the data, place it into the /data folder.  That folder currently contains a small sample of the data for preliminary purposes.  The files are of the same type and name, but each file only contains the first 100 entries of the 1,000,000. The 1M appear to be in a random order, which would imply that the 100 are a random sample.  However, I don't know that they are in a random order.  


First, download the data.  It will come as ~200 files. Put them into /data.  I hope Semantic Scholar can forgive me for including a few lines of each of these files in this repo.  I am happy to remove this if this use is not ok. 

Then, run ```source(file ="scripts/makeMeAGraph.R")```

makeMeAGraph.R runs four scripts in /scripts.  

1) make_incite.R
2) make_pjc.R  
3) make_paperId2JournalIndex.R
4) makeJournalGraph.R   
5) putTogetherEdgeLists.R   
6) make_AdjMat.R  

Each makes new data files in output/data that are then read by the next script.  

**make_incite.R** will create two types of files in output/data/incite.  It will only store data on papers that have year defined, journal defined, and at least one citation *to that paper*.  abc ranges from 000 to 186. 

1)  abc-incite.txt which contains (row,id,year,journal,inEdges). id is the paper id. year is the year published.  journal is the journal it appears in .  inEdges are of the form "paperID1 paperID2 paperID3" where paperID1 is the id for the paper citing the paper in that row. 
2)  abc-inciteEL.RData which contains columns (from,to). It is an edge list for paper citations. 


**make_pjc.R** will make output/data/pjc.RData, a table that containing (paper_id, year, journal_name) for all papers processed by incite (above). This file is over 1GB as an RData file, but expands to ~3GB when loaded into R. It has 45M rows.  

**make_paperId2JournalIndex.R** will create multiple files. output/data/JournalNames.RData is a list of all journal names.  The indexing of that list provides an index for journals. The large file paperId2journalIndex.RData provides a crosswalk from paperId to journalIndex. 

**makeJournalGraph.R** subsamples 5% of the paper-paper citations made by incite.  Then, uses paperId2journalIndex to make them journal-journal edges.  This creates 183 separate files.  **putTogetherEdgeLists.R** puts them into one file.  **make_AdjMat.R** converts the edge lists to an adjacency matrix and names the rows and columns of this matrix.  

outputBig/data/journalAdjMat.RData is the adjacency matrix created by running the above scripts on all of the full data (downloaded on May 28, 2020).




