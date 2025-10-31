CREATE EXTENSION pg_buffercache;

SELECT count(*) AS buffers, relname
FROM pg_buffercache b
JOIN pg_class c ON b.relfilenode = pg_relation_filenode(c.oid)
GROUP BY relname
ORDER BY buffers DESC;
