
begin
    # For scrap data from the website.
    # scripts in the folder "scraping"
    include("getdata.jl");
    
    #Run this after all the files are scraped using getdata.jl
    # This will output "dfsingle" and "dftidy" dataframes
    include("mergefiles.jl") ;
    
    
    # functions for tidy up dataframe
    include("tidy.jl") ;
    
    #mapping countries and their abbreviations ver.2
    include("utilities/mapping_countries.jl") ;
    
    # Utilities functions, for plotting
    include("utilities/utilities.jl") ;
end
    
    #####################