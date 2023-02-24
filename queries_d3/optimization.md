# Protocol for optimization :

### Step 1 : preprocessing :

1 - Produce relational algebra expression for every block in a query

2 - push down selection/ projection

3 - decorrlate queries

4 - flatten queries

5 - only keep joins (cross production + selection) and no cross-product

### Step 2 : Optimization :


<ins>Goal :</ins> Enumerate all logical plans, estimate their global cost and chose the best


1 - estimation of the size of each output of operator (compute approximate reduction factor (potentially in pandas for closer estimate))

2 - enumerate the alternative plans :

a - if only one table : only have to determine the access path that is the most efficient (full scan, index lookup, index only)
b - if multiple tables :
        - only consider left deeo join trees (since it gets fully piplined) 
        - enumerate all possible combinations of join algorithms
        - enumerate all possible access path to the relations
        - determine the cost at each leaf and keep it for the computation of the parent leaf cost