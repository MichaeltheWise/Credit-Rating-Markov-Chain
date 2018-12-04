
# Initial setup
using Pkg;
Pkg.add("DataFrames");

using DataFrames;
raw_data = readtable("raw_data.csv");
size(raw_data)

data = raw_data[raw_data.splticrm .!== missing,:];
size(data)

size(unique(data.tic),1)

by(data, :tic, size)

selected_index = []
for subdf in groupby(data, :tic)
    if size(subdf,1) === 242
        push!(selected_index,subdf.tic[1])
    end
end
size(selected_index,1)

selected_data = data[data.tic .=== selected_index[1],:]
for i in 2:size(selected_index,1)
    temp = data[data.tic .=== selected_index[i],:]
    selected_data = vcat(temp, selected_data)
end
size(selected_data,1)

unique(selected_data.datadate)

unique(selected_data.splticrm)

sort!(selected_data, :datadate)

sort!(selected_data, :splticrm)

rating_string = selected_data.splticrm;
rating_float = Array{Int64}(undef,(size(rating_string,1),1))
for i in 1:size(rating_string,1)
    if rating_string[i] == "AAA"
        rating_float[i] = 22
    elseif rating_string[i] == "AA+"
        rating_float[i] = 21
    elseif rating_string[i] == "AA"
        rating_float[i] = 20
    elseif rating_string[i] == "AA-"
        rating_float[i] = 19
    elseif rating_string[i] == "A+"
        rating_float[i] = 18
    elseif rating_string[i] == "A"
        rating_float[i] = 17
    elseif rating_string[i] == "A-"
        rating_float[i] = 16
    elseif rating_string[i] == "BBB+"
        rating_float[i] = 15
    elseif rating_string[i] == "BBB"
        rating_float[i] = 14
    elseif rating_string[i] == "BBB-"
        rating_float[i] = 13
    elseif rating_string[i] == "BB+"
        rating_float[i] = 12
    elseif rating_string[i] == "BB"
        rating_float[i] = 11
    elseif rating_string[i] == "BB-"
        rating_float[i] = 10
    elseif rating_string[i] == "B+"
        rating_float[i] = 9
    elseif rating_string[i] == "B"
        rating_float[i] = 8
    elseif rating_string[i] == "B-"
        rating_float[i] = 7
    elseif rating_string[i] == "CCC+"
        rating_float[i] = 6
    elseif rating_string[i] == "CCC"
        rating_float[i] = 5
    elseif rating_string[i] == "CCC-"
        rating_float[i] = 4
    elseif rating_string[i] == "CC"
        rating_float[i] = 3
    elseif rating_string[i] == "SD"
        rating_float[i] = 2
    elseif rating_string[i] == "D"
        rating_float[i] = 1 
    end
end
rating_float

delete!(selected_data,:splticrm)

rating_float = convert(DataFrame, rating_float);
rename!(rating_float, :x1 => :rating)

selected_data = hcat(selected_data, rating_float)

sort!(selected_data,:tic)

# using StatsPlots
using Plots
# Select American Airline as the example
AAL = DataFrame(selected_data[selected_data.tic .=== "AAL",:]);
sort!(AAL,:datadate)
date = trunc.(Int, AAL.datadate / 10000)
plot(date, AAL.rating, label = "Rating", title = "American Airline Rating Change")

savefig("AAL_rating.png")

part1_transition_df_with_year_transition = DataFrame(company = String[], singlenotch = Int[], multinotch = Int[], perctmultinotch = Float64[]);
part1_transition_df_without_year_transition = DataFrame(company = String[], singlenotch = Int[], multinotch = Int[], perctmultinotch = Float64[]);
multiple_notch_counter = 0;
single_notch_counter = 0;

for subgroup in groupby(selected_data, :tic)
    subgroup = sort(subgroup,:datadate)
    temp_rating = subgroup.rating
    previous = temp_rating[1]
    multiple_notch_counter = 0
    single_notch_counter = 0
    for i in 2:size(temp_rating,1)
        if abs(temp_rating[i] - previous) > 1
            multiple_notch_counter = multiple_notch_counter + 1
        elseif abs(temp_rating[i] - previous) == 1
            single_notch_counter = single_notch_counter + 1
        end
        previous = temp_rating[i]
    end
    perct = multiple_notch_counter / (single_notch_counter + multiple_notch_counter)
    name = subgroup.tic[1]
    push!(part1_transition_df_with_year_transition, [name, single_notch_counter, multiple_notch_counter, perct])
end
part1_transition_df_with_year_transition

println(sum(part1_transition_df_with_year_transition[:,2]))
println(sum(part1_transition_df_with_year_transition[:,3]))

part2_data = selected_data;
temp_year = trunc.(Int, (part2_data.datadate ./ 10000));
year = DataFrame();
year = hcat(year, temp_year);
rename!(year, :x1 => :year);
part2_data = hcat(part2_data, year)

for subgroup in groupby(part2_data, :tic)
    subgroup = sort(subgroup,:datadate)
    temp_rating = subgroup.rating
    temp_year = subgroup.year
    previous = temp_rating[1]
    previous_year = temp_year[1]
    multiple_notch_counter = 0
    single_notch_counter = 0
    for i in 2:size(temp_rating,1)
        if abs(temp_rating[i] - previous) > 1 && temp_year[i] == previous_year
            multiple_notch_counter = multiple_notch_counter + 1
        elseif abs(temp_rating[i] - previous) == 1 && temp_year[i] == previous_year
            single_notch_counter = single_notch_counter + 1
        end
        previous = temp_rating[i]
        previous_year = temp_year[i]
    end
    perct = multiple_notch_counter / (single_notch_counter + multiple_notch_counter)
    name = subgroup.tic[1]
    push!(part1_transition_df_without_year_transition, [name, single_notch_counter, multiple_notch_counter, perct])
end
part1_transition_df_without_year_transition

println(sum(part1_transition_df_without_year_transition[:,2]))
println(sum(part1_transition_df_without_year_transition[:,3]))

part2_transition_df_without_year_transition = DataFrame(year = Int[1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017], singlenotch = Int[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], multinotch = Int[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], perctmultinotch = Float64[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);
part2_transition_df_with_year_transition = DataFrame(year = Int[1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017], singlenotch = Int[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], multinotch = Int[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], perctmultinotch = Float64[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);
overtime_multinotch_counter = 0;
overtime_singlenotch_counter = 0;

# Still use tic as the separating factor, then slowly accumulate the counter
for subgroup in groupby(part2_data, :tic)
    subgroup = sort(subgroup,:datadate)
    temp_data = DataFrame(subgroup)
    counter = 1
    for subtime in groupby(temp_data, :year)
        temp_rating = subtime.rating
        previous = temp_rating[1]
        overtime_multinotch_counter = 0
        overtime_singlenotch_counter = 0
        for i in 2:size(temp_rating,1)
            if abs(temp_rating[i] - previous) > 1
                overtime_multinotch_counter = overtime_multinotch_counter + 1
            elseif abs(temp_rating[i] - previous) == 1
                overtime_singlenotch_counter = overtime_singlenotch_counter + 1
            end
            previous = temp_rating[i]
        end
        part2_transition_df_without_year_transition[counter,2] = part2_transition_df_without_year_transition[counter,2] + overtime_singlenotch_counter
        part2_transition_df_without_year_transition[counter,3] = part2_transition_df_without_year_transition[counter,3] + overtime_multinotch_counter
        counter = counter + 1
    end
end
part2_transition_df_without_year_transition.perctmultinotch = part2_transition_df_without_year_transition.multinotch ./ (part2_transition_df_without_year_transition.multinotch + part2_transition_df_without_year_transition.singlenotch)
part2_transition_df_without_year_transition

println(sum(part2_transition_df_without_year_transition[:,2]))
println(sum(part2_transition_df_without_year_transition[:,3]))

# Testing ground 
for subgroup in groupby(part2_data, :tic)
    subgroup = sort(subgroup,:datadate)
    A = subgroup[subgroup.year .=== 2017,:]
    println(A)
    break
end

for subgroup in groupby(part2_data, :tic)
    subgroup = sort(subgroup,:datadate)
    temp_data = DataFrame(subgroup)
    counter = 1
    init_flag = 0
    previous_year = 0
    for subtime in groupby(temp_data, :year)
        temp_rating = subtime.rating
        previous = temp_rating[1]
        overtime_multinotch_counter = 0
        overtime_singlenotch_counter = 0
        
        if init_flag == 0
            previous_year = temp_rating[end]
        elseif init_flag == 1
            if abs(previous - previous_year) > 1
                overtime_multinotch_counter = overtime_multinotch_counter + 1
            elseif abs(previous - previous_year) == 1
                overtime_singlenotch_counter = overtime_singlenotch_counter + 1
            end
            previous_year = temp_rating[end]
        end
            
        for i in 2:size(temp_rating,1)
            if abs(temp_rating[i] - previous) > 1
                overtime_multinotch_counter = overtime_multinotch_counter + 1
            elseif abs(temp_rating[i] - previous) == 1
                overtime_singlenotch_counter = overtime_singlenotch_counter + 1
            end
            previous = temp_rating[i]
        end
        part2_transition_df_with_year_transition[counter,2] = part2_transition_df_with_year_transition[counter,2] + overtime_singlenotch_counter
        part2_transition_df_with_year_transition[counter,3] = part2_transition_df_with_year_transition[counter,3] + overtime_multinotch_counter
        counter = counter + 1
        init_flag = 1
    end
end
part2_transition_df_with_year_transition.perctmultinotch = part2_transition_df_with_year_transition.multinotch ./ (part2_transition_df_with_year_transition.multinotch + part2_transition_df_with_year_transition.singlenotch)
part2_transition_df_with_year_transition

println(sum(part2_transition_df_with_year_transition[:,2]))
println(sum(part2_transition_df_with_year_transition[:,3]))

transition_matrix_array = [];

transition_data = selected_data;
temp_month = trunc.(Int, (transition_data.datadate - (trunc.(Int, (transition_data.datadate ./ 10000)) * 10000)) ./ 100);
month = DataFrame();
month = hcat(year, temp_month);
rename!(month, :x1 => :month);
transition_data = hcat(transition_data, month)

# Storing data into a total transition matrix just in case
total_transition_matrix = DataFrame()
# A quick creation of transition matrix using for loop
for i in 1:22
    temp = Array([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
    total_transition_matrix = hcat(total_transition_matrix, temp)
end
rename!(total_transition_matrix, Dict(:x1 => Symbol("D"), :x1_1 => Symbol("SD"), :x1_2 => Symbol("CC"), :x1_3 => Symbol("CCC-"), :x1_4 => Symbol("CCC"), :x1_5 => Symbol("CCC+"), :x1_6 => Symbol("B-"), :x1_7 => Symbol("B"), :x1_8 => Symbol("B+"), :x1_9 => Symbol("BB-"), :x1_10 => Symbol("BB"), :x1_11 => Symbol("BB+"), :x1_12 => Symbol("BBB-"), :x1_13 => Symbol("BBB"), :x1_14 => Symbol("BBB+"), :x1_15 => Symbol("A-"), :x1_16 => Symbol("A"), :x1_17 => Symbol("A+"), :x1_18 => Symbol("AA-"), :x1_19 => Symbol("AA"), :x1_20 => Symbol("AA+"), :x1_21 => Symbol("AAA")));

summation = 0
sort!(transition_data,:datadate)
for subtime in groupby(transition_data, :year)
    subtime = sort(subtime, :datadate)
    temp_data = DataFrame(subtime)
    
    transition_matrix = DataFrame()
    for i in 1:22
        temp = Array([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
        transition_matrix = hcat(transition_matrix, temp)
    end
    rename!(transition_matrix, Dict(:x1 => Symbol("D"), :x1_1 => Symbol("SD"), :x1_2 => Symbol("CC"), :x1_3 => Symbol("CCC-"), :x1_4 => Symbol("CCC"), :x1_5 => Symbol("CCC+"), :x1_6 => Symbol("B-"), :x1_7 => Symbol("B"), :x1_8 => Symbol("B+"), :x1_9 => Symbol("BB-"), :x1_10 => Symbol("BB"), :x1_11 => Symbol("BB+"), :x1_12 => Symbol("BBB-"), :x1_13 => Symbol("BBB"), :x1_14 => Symbol("BBB+"), :x1_15 => Symbol("A-"), :x1_16 => Symbol("A"), :x1_17 => Symbol("A+"), :x1_18 => Symbol("AA-"), :x1_19 => Symbol("AA"), :x1_20 => Symbol("AA+"), :x1_21 => Symbol("AAA")))
    
    for subgroup in groupby(temp_data, :tic)
        temp_rating = subgroup.rating
        previous = temp_rating[1]
        
        for i in 2:size(temp_rating,1)
            transition_matrix[previous,temp_rating[i]] += 1
            total_transition_matrix[previous,temp_rating[i]] += 1
            previous = temp_rating[i]
        end
    end
    
    # Add to the transition_matrix_array
    push!(transition_matrix_array, transition_matrix) 
end
size(transition_matrix_array,1)

total_transition_matrix

transition_matrix_array[2]

# Testing ground
result = 0
transition = []
for i in 1:21
    for row in 1:size(transition_matrix_array[i],1)
        for column in 1:size(transition_matrix_array[i],1)
            if row != column
                result += transition_matrix_array[i][row,column]
            end
        end
    end
    push!(transition, result)
    result = 0
end
transition

total_transition_probability_matrix = DataFrame(x1 = [], x1_1 = [], x1_2 = [], x1_3 = [], x1_4 = [], x1_5 = [], x1_6 = [], x1_7 = [], x1_8 = [], x1_9 = [], x1_10 = [], x1_11 = [], x1_12 = [], x1_13 = [], x1_14 = [], x1_15 = [], x1_16 = [], x1_17 = [], x1_18 = [], x1_19 = [], x1_20 = [], x1_21 = []);
rename!(total_transition_probability_matrix, Dict(:x1 => Symbol("D"), :x1_1 => Symbol("SD"), :x1_2 => Symbol("CC"), :x1_3 => Symbol("CCC-"), :x1_4 => Symbol("CCC"), :x1_5 => Symbol("CCC+"), :x1_6 => Symbol("B-"), :x1_7 => Symbol("B"), :x1_8 => Symbol("B+"), :x1_9 => Symbol("BB-"), :x1_10 => Symbol("BB"), :x1_11 => Symbol("BB+"), :x1_12 => Symbol("BBB-"), :x1_13 => Symbol("BBB"), :x1_14 => Symbol("BBB+"), :x1_15 => Symbol("A-"), :x1_16 => Symbol("A"), :x1_17 => Symbol("A+"), :x1_18 => Symbol("AA-"), :x1_19 => Symbol("AA"), :x1_20 => Symbol("AA+"), :x1_21 => Symbol("AAA")));
for row = 1:size(total_transition_matrix,1)
    temp_row = convert(Array, total_transition_matrix[row,:]) / sum(convert(Array, total_transition_matrix[row,:]))
    push!(total_transition_probability_matrix, temp_row)
end
total_transition_probability_matrix




