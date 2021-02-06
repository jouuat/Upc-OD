// ORGANIZATION INSERTION
CREATE INDEX ON :Organization(name, type);

WITH ['university', 'company'] AS types
WITH types, ['Organization 1', 'Organization 2', 'Organization 3', 'Organization 4', 'Organization 5', 'Organization 6'] AS organizations
UNWIND organizations AS org
WITH org, types[toInteger(round(rand()))] AS t
CREATE (:Organization {name:org, type:t});

// AUTHOR FROM ORGANIZATION INSERTION
MATCH (o:Organization)
WITH COLLECT(o) AS organizations
MATCH (s:Scientific)
WITH s, organizations[toInteger(rand()*(SIZE(organizations)-1))] AS a
CREATE (s)-[:is_affiliated]->(a);

// ADD REQUIRED_REVIEWERS TO CONFERENCES
MATCH (c:Conference)
SET c.required_reviewers = toInteger(ceil(rand()*3))
RETURN c;

// ADD REQUIRED_REVIEWERS TO JOURNALS
MATCH (j:Journal)
SET j.required_reviewers = toInteger(round(rand()*3))
RETURN j;
