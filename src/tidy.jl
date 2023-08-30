using DataFrames


"""
Tidy up the dataset.
go through each column in df
if the value in that column is a vector 
create a new column, with the first column name follows by "_" then the sub column name 
if the value is null, or false, turn them into either "" or 0.0, or 0, depend on the type of that column

"""

#define functions for identifying types of each column
union_types(x::Union) = (x.a, union_types(x.b)...)
union_types(x::Type) = (x,)
"""
This function goes through each column in the dataframe (df)
    and replaces missing/nothing values with appropriate datatype.
"""
function check1!(df::DataFrame)
    # separate columns with nothing only or single type only, out
    colnames = names(df)
    keep_columns1 = ones(Bool, length(colnames))

    for i in eachindex(colnames) #loop each column

        name = colnames[i] #get the name of that column

        #get the types of the column
        types = collect(union_types(eltype(df[!, i])))

        #check if there is more than 2 types in the column
        if size(types)[1] > 2  #normally , there are only 2 types in a column
            println(size(types))
            println("Column $i has more than 2 types")
        end

        #check column with only nothing (has 1 type and that type is the Nothing type)
        if (Nothing in types) & (size(types)[1] == 1)
            # println("Column $i is a vector of nothing")
            keep_columns1[i] = false #disgarding that column
        #THIS PART IS DONE

        else
            Ts = [String, Bool, Int64, Float64] #possible types of column
            Tsval = ["", false, 0, 0.0] #missing values for those types
            if size(types)[1] == 2  #probably nothing and something
                for ti in eachindex(Ts) #loop datatypes.
                    t = Ts[ti]
                    valt = Tsval[ti]
                    if t in types
                        # println("Column $i, $name is a vector of $t")
                        #initiate the whole column in to a vector of a single type, 
                        #then replace the original column with the vector
                        vec = Vector{t}(undef, size(df)[1])
                        for j in eachindex(df[!, i])
                            if df[j, i] === nothing
                                vec[j] = valt
                            else
                                vec[j] = df[j, i]
                            end
                        end
                        df[!, i] = vec
                        println("Column $i, $name is fixed and now a vector of $t")
                        break # if it's already found that type, does not have to keep looking anymore.

                    end
                end

            elseif size(types)[1] > 2 #just in case I missed
                println("Column $i has more than 2 types")
                println("Please recheck the data")

            end
        end
    end
    return keep_columns1
end


"""
separte columns that have single type (easy visualization and analysis)
    from columns that have multiple types (need to be separated)
    and also columns that have only 0 values.
"""
function check2(df_tidy1::DataFrame)
    tidycolnames = names(df_tidy1)
    keep_columns2 = ones(Bool, length(tidycolnames))
    singletype_columns = zeros(Bool, length(tidycolnames))

    for i in eachindex(tidycolnames)
        name = tidycolnames[i]

        #check if there is a vector in the column
        #criterias to remove a column
        types = collect(union_types(eltype(df_tidy1[!, i])))


        # if size(types)[1] > 2 
        #     println(size(types))
        #     println("Column $i has more than 2 types")
        # end

        # if (Nothing in types)  & (size(types)[1] == 1)
        #     println("*",name)
        #     # println("Column $i is a vector of nothing")
        #     keep_columns1[i] = false
        #     #THIS PART IS DONE
        # else 
        #     println(name)
        # end


        # println("Column $i is ", types)
        if size(types)[1] == 1
            # println("Column $i is ", types)
            if types[1] == String
                singletype_columns[i] = true
            elseif types[1] == Bool
                singletype_columns[i] = true
            elseif types[1] == Int64
                singletype_columns[i] = true
            elseif types[1] == Float64
                singletype_columns[i] = true
                # println("$i is " ,types)

                # elseif isa(types[1] , Dict)
            else
                # println("#"^10)
                # println(name)
                # println(types)
            end
            # println("Column $i is a vector of ", types)
        end


        if all(df_tidy1[!, i] .== 0) || all(df_tidy1[!, i] .== "") || all(df_tidy1[!, i] .== false)
            println("All nothing at ", i, " ", name)
            keep_columns2[i] = false
        end

    end

    return keep_columns2, singletype_columns
end