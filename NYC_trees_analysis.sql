-- Let's examine the data set for trees in NY
SELECT * FROM `bigquery-public-data.new_york_trees.tree_census_2015`;

-- Let's see the total number of trees in NY
SELECT COUNT(*) FROM `bigquery-public-data.new_york_trees.tree_census_2015`;

-- Trees in poor health in each zipcode
SELECT zipcode, COUNT(*) n_trees
FROM `bigquery-public-data.new_york_trees.tree_census_2015`
GROUP BY zipcode
ORDER BY n_trees DESC;

-- We can classify the trees depending on their health status, for each zipcode
SELECT
    zipcode,
    COUNT(*) n_trees,
    SUM(CASE WHEN status = 'Alive' THEN 1 ELSE 0 END) n_alive,
    SUM(CASE WHEN health = 'Good' THEN 1 ELSE 0 END) n_good,
    SUM(CASE WHEN health = 'Fair' THEN 1 ELSE 0 END) n_fair,
    SUM(CASE WHEN health = 'Poor' THEN 1 ELSE 0 END) n_poor,

FROM `bigquery-public-data.new_york_trees.tree_census_2015`
GROUP BY zipcode
ORDER BY n_trees DESC;

-- We can use subqueries to determine the zipcode with the lowest percentage of alive trees; only 12 trees in that zipcode however
SELECT
    zipcode, n_trees , n_alive, n_good, n_fair, n_poor,
    ROUND(n_alive/n_trees*100,1) perc_alive,
    ROUND(n_good/n_alive*100,1) perc_good,
    ROUND(n_fair/n_alive*100,1) perc_fair,
    ROUND(n_poor/n_alive*100,1) perc_poor

FROM
(
    SELECT
        zipcode,
        COUNT(*) n_trees,
        SUM(CASE WHEN status = 'Alive' THEN 1 ELSE 0 END) n_alive,
        SUM(CASE WHEN health = 'Good' THEN 1 ELSE 0 END) n_good,
        SUM(CASE WHEN health = 'Fair' THEN 1 ELSE 0 END) n_fair,
        SUM(CASE WHEN health = 'Poor' THEN 1 ELSE 0 END) n_poor,
    FROM `bigquery-public-data.new_york_trees.tree_census_2015`
    GROUP BY zipcode
) A
ORDER BY perc_alive

-- Another method we can use is create a temporary table and reference it which will give the same result as the query above
WITH count_nyc_trees AS
(
    SELECT
        zipcode,
        COUNT(*) n_trees,
        SUM(CASE WHEN status = 'Alive' THEN 1 ELSE 0 END) n_alive,
        SUM(CASE WHEN health = 'Good' THEN 1 ELSE 0 END) n_good,
        SUM(CASE WHEN health = 'Fair' THEN 1 ELSE 0 END) n_fair,
        SUM(CASE WHEN health = 'Poor' THEN 1 ELSE 0 END) n_poor,
    FROM `bigquery-public-data.new_york_trees.tree_census_2015`
    GROUP BY zipcode
)
SELECT
    zipcode, n_trees , n_alive, n_good, n_fair, n_poor,
    ROUND(n_alive/n_trees*100,1) perc_alive,
    ROUND(n_good/n_alive*100,1) perc_good,
    ROUND(n_fair/n_alive*100,1) perc_fair,
    ROUND(n_poor/n_alive*100,1) perc_poor
FROM count_nyc_trees
ORDER BY perc_alive;

-- We can look at the growth of trees from different years (1995, 2005, 2015)
SELECT CAST(zipcode AS STRING) zipcode, SUM(CASE WHEN status = 'Alive' THEN 1 ELSE 0 END) n_healthy, 2015 AS year
FROM `bigquery-public-data.new_york_trees.tree_census_2015`
WHERE zipcode <> 83
GROUP BY zipcode
UNION ALL
SELECT zipcode, SUM(CASE WHEN status = 'Good' THEN 1 ELSE 0 END) n_healthy, 2005 AS year
FROM `bigquery-public-data.new_york_trees.tree_census_2005`
WHERE zipcode <> '0'
GROUP BY zipcode
UNION ALL
SELECT CAST(zip_new AS STRING) zipcode, SUM(CASE WHEN status = 'Good' THEN 1 ELSE 0 END) n_healthy, 1995 AS year
FROM `bigquery-public-data.new_york_trees.tree_census_1995`
WHERE zip_new <> 0
GROUP BY zipcode;

-- Let's save the results from the above query into a new table 'nyc_alive_trees' to further analyze
-- Here we will use the LAG function to compare the trees across the years. Also, we want the LAG's to take place within partitions, using PARTITIONS BY. Here, the partition is zipcode
SELECT
    * ,
    n_healthy - LAG(n_healthy,1) OVER (PARTITION BY zipcode ORDER BY year)diff_healthy_1_period_ago,
    n_healthy - LAG(n_healthy,2) OVER (PARTITION BY zipcode ORDER BY year)diff_healthy_2_period_ago
FROM `ba775-jlp.temp_dataset.nyc_alive_trees`
ORDER BY zipcode, year;

-- It is more interesting to see the present (2015) and compare the growth of trees by zipcode.
SELECT * FROM
(
    SELECT
        * ,
        n_healthy - LAG(n_healthy,1) OVER (PARTITION BY zipcode ORDER BY year)diff_healthy_1_period_ago,
        n_healthy - LAG(n_healthy,2) OVER (PARTITION BY zipcode ORDER BY year)diff_healthy_2_period_ago
    FROM `ba775-jlp.temp_dataset.nyc_alive_trees`
    ORDER BY zipcode, year
)
WHERE year = 2015 AND diff_healthy_2_period_ago IS NOT NULL;

-- This is what the above query would look like had we not used the temp table 'nyc_alive_trees'
SELECT * FROM
(
    SELECT
        * ,
        n_healthy - LAG(n_healthy,1) OVER (PARTITION BY zipcode ORDER BY year)diff_healthy_1_period_ago,
        n_healthy - LAG(n_healthy,2) OVER (PARTITION BY zipcode ORDER BY year)diff_healthy_2_period_ago
    FROM
        (
            SELECT CAST(zipcode AS STRING) zipcode, SUM(CASE WHEN status = 'Alive' THEN 1 ELSE 0 END) n_healthy, 2015 AS year
            FROM `bigquery-public-data.new_york_trees.tree_census_2015`
            WHERE zipcode <> 83
            GROUP BY zipcode
            UNION ALL
            SELECT zipcode, SUM(CASE WHEN status = 'Good' THEN 1 ELSE 0 END) n_healthy, 2005 AS year
            FROM `bigquery-public-data.new_york_trees.tree_census_2005`
            WHERE zipcode <> '0'
            GROUP BY zipcode
            UNION ALL
            SELECT CAST(zip_new AS STRING) zipcode, SUM(CASE WHEN status = 'Good' THEN 1 ELSE 0 END) n_healthy, 1995 AS year
            FROM `bigquery-public-data.new_york_trees.tree_census_1995`
            WHERE zip_new <> 0
            GROUP BY zipcode
        )
    ORDER BY zipcode, year
)
WHERE year = 2015 AND diff_healthy_2_period_ago IS NOT NULL;

-- Let's save the above query as a view with the name 'nyc_trees_added' and call it
SELECT * FROM `ba775-jlp.examples.nyc_trees_added`

-- Let's see which zipcode has had the biggest number of total trees added since 2005
SELECT * FROM `ba775-jlp.examples.nyc_trees_added`
ORDER BY diff_healthy_1_period_ago DESC;

-- We can also check which zipcode has had the biggest number of total trees added since 2005 based on percentage. Zipcode 10018 had a huge increase! From 53 to 441
SELECT * FROM `ba775-jlp.examples.nyc_trees_added`
ORDER BY diff_healthy_1_period_ago/n_healthy DESC;
