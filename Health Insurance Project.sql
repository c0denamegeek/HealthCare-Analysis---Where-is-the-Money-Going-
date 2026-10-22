-- Healthcare Claims - Where Is the Money Going?
-- Calculate total paid amount per member.
WITH top_members AS (
    SELECT TOP 10
        member_id,
        SUM(paid_amount) AS member_total_paid
    FROM [Health_Insurance].[dbo].[claims]
    GROUP BY member_id
    ORDER BY member_total_paid DESC
)
SELECT
    t.member_id,
    t.member_total_paid,
    c.claim_type,
    COUNT(*) AS claim_count,
    SUM(c.paid_amount) AS paid_by_type,
    ROUND(SUM(c.paid_amount) * 100.0 / t.member_total_paid, 1) AS pct_of_member_cost
FROM top_members t
JOIN [Health_Insurance].[dbo].[claims] c
    ON c.member_id = t.member_id
GROUP BY t.member_id, t.member_total_paid, c.claim_type
ORDER BY t.member_total_paid DESC, paid_by_type DESC;

-- 1. Claim Type Cost Breakdown
SELECT 
	claim_type, 
	COUNT(*) AS number_of_claims,
	ROUND(SUM(billed_amount), 2) AS total_billed, 
	ROUND(SUM(paid_amount), 2) AS total_paid
FROM [Health_Insurance].[dbo].[claims]
GROUP BY claim_type

-- 2. CPT & ICD Cost Drivers
-- CPT Drivers Top 10
SELECT TOP 10
	cpt_code, 
	SUM(paid_amount) AS total_paid
FROM [Health_Insurance].[dbo].[claims]
GROUP BY cpt_code
ORDER BY total_paid DESC

-- ICD Drivers Top 10
SELECT TOP 10
	icd_code, 
	SUM(paid_amount) AS total_paid
FROM [Health_Insurance].[dbo].[claims]
GROUP BY icd_code
ORDER BY total_paid DESC

-- CPT Codes with High Paid Amount Per Claim
SELECT 
	cpt_code,
	SUM(paid_amount) / count(claim_id) AS avg_paid_per_claim
FROM [Health_Insurance].[dbo].[claims] 
GROUP BY cpt_code
ORDER BY avg_paid_per_claim DESC

-- 3. Member-Level Analysis
-- Calculate total paid amount per member
SELECT
	c.member_id, 
	SUM(paid_amount) AS total_paid
FROM [Health_Insurance].[dbo].[claims] c
INNER JOIN [Health_Insurance].[dbo].[members] m
    ON c.member_id = m.member_id
GROUP BY c.member_id
ORDER BY total_paid DESC

-- Identify the top 5–10 highest-cost members.
SELECT TOP 10
	c.member_id, 
	SUM(paid_amount) AS member_cost
FROM [Health_Insurance].[dbo].[claims] c
INNER JOIN [Health_Insurance].[dbo].[members] m
    ON c.member_id = m.member_id
GROUP BY c.member_id
ORDER BY member_cost DESC

-- 4. Billed v Paid Ratio 
SELECT
    SUM(billed_amount) AS total_billed,
    SUM(paid_amount) AS total_paid,
    ROUND(SUM(paid_amount) / SUM(billed_amount), 2) AS overall_paid_ratio
FROM [Health_Insurance].[dbo].[claims] c;

-- Claim Type
SELECT
    claim_type,
    COUNT(*) AS claim_count,
    ROUND(SUM(billed_amount), 2) AS total_billed,
    ROUND(SUM(paid_amount), 2) AS total_paid,
    ROUND(SUM(paid_amount) * 1.0 / NULLIF(SUM(billed_amount), 0), 2) AS paid_ratio
FROM [Health_Insurance].[dbo].[claims]
GROUP BY claim_type
ORDER BY paid_ratio;

-- CPT Code
SELECT
    cpt_code,
    COUNT(*) AS claim_count,
    ROUND(SUM(billed_amount), 2) AS total_billed,
    ROUND(SUM(paid_amount), 2) AS total_paid,
    ROUND(SUM(paid_amount) * 1.0 / NULLIF(SUM(billed_amount), 0), 2) AS paid_ratio
FROM [Health_Insurance].[dbo].[claims]
GROUP BY cpt_code
HAVING COUNT(*) >= 30
ORDER BY paid_ratio;

-- Provider
SELECT
    provider_id,
    COUNT(*) AS claim_count,
    ROUND(SUM(billed_amount), 2) AS total_billed,
    ROUND(SUM(paid_amount), 2) AS total_paid,
    ROUND(SUM(paid_amount) * 1.0 / NULLIF(SUM(billed_amount), 0), 2) AS paid_ratio
FROM [Health_Insurance].[dbo].[claims]
GROUP BY provider_id
HAVING COUNT(*) >= 30
ORDER BY paid_ratio;

