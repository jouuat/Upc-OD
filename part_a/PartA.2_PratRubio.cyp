// AUTHORS INSERTION
CREATE INDEX ON :Scientific(name);

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM "file:///articles_mock.csv" AS row FIELDTERMINATOR ';'
WITH row, split(row.author, "|") AS authors
UNWIND authors AS author
MERGE (s:Scientific {name:author});

// CONFERENCES INSERTION
CREATE INDEX ON :Conference(name);

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM "file:///conferences_mock.csv" AS row FIELDTERMINATOR ';'
WITH row
WHERE NOT row.name IS NULL
MERGE (c:Conference {name:row.name});

// EDITIONS INSERTION
CREATE INDEX ON :Edition(year);

WITH [2013, 2014, 2015, 2016, 2017, 2018] AS years
MATCH (c:Conference)
UNWIND years AS y
CREATE (e:Edition {year:y})
CREATE (e)-[:part_of]->(c);


// JOURNALS INSERTION
CREATE INDEX ON :Journal(title);

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM "file:///journals_mock.csv" AS row FIELDTERMINATOR ';'
WITH row
WHERE NOT row.name IS NULL
MERGE (j:Journal {title:row.name});

// VOLUMES INSERTION
CREATE INDEX ON :Volume(number, year);

WITH [1, 2, 3, 4] AS n_vol
MATCH (j:Journal)
UNWIND n_vol AS n
CREATE (v:Volume {number:n, year:(2013 + n)})
CREATE (v)-[:belongs_to]->(j);

// ARTICLES INSERTION
CREATE INDEX ON :Article(id, title);

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM "file:///articles_mock.csv" AS row FIELDTERMINATOR ';'
WITH row, SPLIT(row.pages, "-") AS pages
WHERE NOT row.pages IS NULL AND NOT row.title IS NULL AND NOT pages[0] IS NULL AND NOT pages[1] IS NULL
MERGE (a:Article {id:row.id, title:row.title, pages:coalesce((toInteger(pages[1]) - toInteger(pages[0]) +1),1)})
WITH a, row, split(row.author, "|") AS authors
UNWIND authors AS author
MATCH (s:Scientific {name:author})
MERGE (s)-[:writes]->(a);

// ARTICLE PUBLISHED IN EDITION INSERTION
MATCH (e:Edition)
WITH COLLECT(e) AS editions
MATCH (a:Article)
WHERE rand() > 0.5
WITH a, editions[toInteger(rand()*(SIZE(editions)-1))] AS ed
CREATE (a)-[:published_in]->(ed);

// ARTICLE PUBLISHED IN VOLUME INSERTION
MATCH (v:Volume)
WITH COLLECT(v) AS volumes
MATCH (a:Article) 
WHERE NOT (a)-[:published_in]->()
WITH a, volumes[toInteger(rand()*(SIZE(volumes)-1))] AS vol
CREATE (a)-[:published_in]->(vol);

// KEYWORDS INSERTION
CREATE INDEX ON :Keyword(topic);

WITH ['data management', 'indexing', 'data modeling', 'big data', 'data processing', 'data storage', 'data querying', 'computer architecture', 'artificial intelligence', 'software development', 'robotics', 'sensor systems', 'wireless communication', 'security', 'cloud storage', 'human computer interactions', 'open source software', 'machine learning', 'data visualization'] AS topics
MATCH (a:Article)
WITH a, topics, length(topics) AS l_topics
WITH a, topics, round(rand()*(l_topics-1)) AS pos1, round(rand()*(l_topics-1)) AS pos2, round(rand()*(l_topics-1)) AS pos3
WITH a, topics[toInteger(pos1)] AS t1, topics[toInteger(pos2)] AS t2, topics[toInteger(pos3)] AS t3
MERGE (k1:Keyword {topic:t1})
CREATE (a)-[:has]->(k1)
WITH a, t2, t3
WHERE rand() > 0.5
MERGE (k2:Keyword {topic:t2})
MERGE (a)-[:has]->(k2)
WITH a, t3
WHERE rand() > 0.5
MERGE (k3:Keyword {topic:t3})
MERGE (a)-[:has]->(k3);


// CITES INSERTION
MATCH (a:Article), (b:Article)
MATCH (a)-[:published_in]->(x)
MATCH (b)-[:published_in]->(y)
WITH a, b, x.year AS a_date, y.year AS b_date
WHERE rand() > 0.9 AND a<>b AND a_date >= b_date AND NOT (b)-[:cites]->(a)
CREATE (a)-[:cites]->(b);

// REVIEWS INSERTION
MATCH (a:Scientific) 
WITH a, rand() as r
ORDER BY r
WITH COLLECT(a) as rev
WITH rev[0..3] as reviewers
MATCH (p:Article)
UNWIND reviewers as reviewer
WITH reviewer, p
WHERE NOT (reviewer)-[:writes]->(p)
CREATE (reviewer)-[:reviews]->(p);