// BETWEENNESS CENTRALITY ALGORITHM
CALL algo.betweenness.stream(’Article’,’cites’,{direction:’out’})
YIELD nodeId, centrality
MATCH (a:Article) WHERE id(a) = nodeId
RETURN a.title AS article,centrality
ORDER BY centrality DESC;

// STRONGLY CONNECTED COMPONENTS ALGORITHM
CALL algo.scc.stream(
’MATCH (s:Scientific) RETURN id(s) as id’,
’MATCH (s1:Scientific)-[:writes]->(:Article)-[:cites]->(:Article)<-[:writes]-
(s2:Scientific) RETURN id(s1) as source,id(s2) as target’,
{write:true,graph:’cypher’})
YIELD nodeId, partition
WITH partition, COLLECT(nodeId) AS participants
RETURN partition, SIZE(participants) AS n_participants, participants
ORDER BY n_participants DESC;