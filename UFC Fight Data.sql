-- Download Dataset: https://www.kaggle.com/datasets/remypereira/mma-dataset-2023-ufc

SET SESSION sql_mode = ' ';

CREATE DATABASE UFC_Dataset_2023;
-- Import data from dataset into to database.
-- 4 tables total: ufc_event_data, ufc_fight_data, ufc_fight_stat_data and ufc_fighter_data.

-- What are the top 10 submissions used in UFC history?
SELECT result_details AS Submission, COUNT(*) AS Total
	FROM ufc_fight_data
    WHERE result ='Submission'
    GROUP BY result_details
    ORDER BY COUNT(*) DESC
    LIMIT 10; 

-- What are the top 10 KO/TKO techniques used in UFC history?
SELECT result_details AS Attack, COUNT(*) AS Total
	FROM ufc_fight_data
    WHERE result = 'KO/TKO'
    GROUP BY result_details
    ORDER BY COUNT(*) DESC
    LIMIT 10;

-- What is the total number and percentage of Subs, KOs, Decisions, Doctor's stoppages, DQs and fights?
SELECT (SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'Submission') AS Total_Subs,
		(SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'Submission')/COUNT(result) * 100 AS Sub_Pct,
		(SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'KO/TKO') AS Total_KOs,
        (SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'KO/TKO')/COUNT(result) * 100 AS KO_Pct,
        (SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'Decision') AS Total_Decs,
        (SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'Decision')/COUNT(result) * 100 AS Dec_Pct,
        (SELECT COUNT(result) FROM ufc_fight_data WHERE result = "TKO - Doctor's stoppage") AS Doc_stoppage,
        (SELECT COUNT(result) FROM ufc_fight_data WHERE result = "TKO - Doctor's stoppage")/COUNT(result) * 100 AS Doc_Stop_Pct,
        (SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'DQ') AS DQs,
        (SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'DQ')/COUNT(result) * 100 AS DQ_Pct,
		COUNT(result) AS Total_Fights
	FROM ufc_fight_data;

-- When do most submissions occur?
SELECT result, AVG(finish_round)
	FROM ufc_fight_data
    WHERE result = 'Submission';

-- When do most KO/TKOs occur?
SELECT result, AVG(finish_round)
	FROM ufc_fight_data
    WHERE result = 'KO/TKO';

-- What percentage of fights ended in submission between 1/1/15 and 12/31/19?
-- Dates can be modifed to include other ranges. 
SELECT 
		COUNT(result) AS total_subs,
			(SELECT COUNT(result) FROM ufc_fight_data 
            JOIN ufc_event_data ON ufc_fight_data.event_id = ufc_event_data.event_id
            WHERE event_date BETWEEN '2015-01-01' AND '2019-12-31') AS total_fights,
		COUNT(result) / 
			(SELECT COUNT(result) FROM ufc_fight_data 
            JOIN ufc_event_data ON ufc_fight_data.event_id = ufc_event_data.event_id
            WHERE event_date BETWEEN '2015-01-01' AND '2019-12-31') * 100 AS Sub_Pct
	FROM ufc_fight_data
    JOIN ufc_event_data ON ufc_fight_data.event_id = ufc_event_data.event_id
    WHERE event_date BETWEEN '2015-01-01' AND '2019-12-31' AND result = 'Submission';

-- What percentage of fights ended in submission between after 1/1/20?
SELECT 
		COUNT(result) AS total_subs,
			(SELECT COUNT(result) FROM ufc_fight_data 
            JOIN ufc_event_data ON ufc_fight_data.event_id = ufc_event_data.event_id
            WHERE event_date >= '2020-01-01') AS total_fights,
		COUNT(result) / 
			(SELECT COUNT(result) FROM ufc_fight_data 
            JOIN ufc_event_data ON ufc_fight_data.event_id = ufc_event_data.event_id
            WHERE event_date >= '2020-01-01') * 100 AS Sub_Pct
	FROM ufc_fight_data
    JOIN ufc_event_data ON ufc_fight_data.event_id = ufc_event_data.event_id
    WHERE event_date >= '2020-01-01' AND result = 'Submission';

-- What is the total number and percentage of Submissions, KOs and fights?
SELECT (SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'Submission') AS Total_Subs,
		(SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'Submission')/COUNT(result) * 100 AS Sub_Pct,
		(SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'KO/TKO') AS Total_KOs,
        (SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'KO/TKO')/COUNT(result) * 100 AS KO_Pct,
		COUNT(result) AS Total_Fights
	FROM ufc_fight_data;

-- What is the total number of decisions, decision percentage and fights?
SELECT (SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'Decision') AS Total_Decs,
        (SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'Decision')/COUNT(result) * 100 AS Dec_Pct,
        COUNT(result) AS Total_Fights
	FROM ufc_fight_data;

-- What is the average takedown attempt, takedown success, sub attempt and control time?
SELECT 
		AVG(takedown_att) AS avg_takedown_att,
		AVG(takedown_succ) AS avg_takedown_succ,
        AVG(submission_att) AS avg_sub_att,
        TIME(AVG(ctrl_time)) AS avg_ctrl_time
	FROM ufc_fight_stat_data;
 
-- What is the average takedown attempt, takedown success, sub attempt and control time of the fights that went to decision?
 SELECT 
		AVG(takedown_att) AS avg_takedown_att,
		AVG(takedown_succ) AS avg_takedown_succ,
        AVG(submission_att) AS avg_sub_att,
		TIME(AVG(ctrl_time)) AS avg_ctrl_time
	FROM ufc_fight_stat_data
    JOIN ufc_fight_data ON ufc_fight_stat_data.fight_id = ufc_fight_data.fight_id
    JOIN ufc_event_data ON ufc_fight_data.event_id = ufc_event_data.event_id
    WHERE result = 'Decision';
 
 -- How many submissions were finished on the lower half of the body?
 SELECT result, result_details, COUNT(*) AS Total,
		(SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'Submission') AS Total_Subs,
        COUNT(*) / (SELECT COUNT(result) FROM ufc_fight_data WHERE result = 'Submission') * 100 AS Pct_Total_Subs
	FROM ufc_fight_data
    WHERE result = 'Submission' AND result_details LIKE 'Heel Hook%' 
		OR result_details LIKE 'Kneebar%' 
		OR result_details LIKE 'Ankle%'
    GROUP BY result_details WITH ROLLUP
    ORDER BY Total;

 -- Which division had the most fights in UFC history?
 SELECT weight_class, COUNT(*) AS Total
	FROM ufc_fight_data
    GROUP BY weight_class
    ORDER BY Total DESC;