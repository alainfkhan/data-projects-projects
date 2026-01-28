-- list databases
SELECT name
FROM master.sys.databases
WHERE name = '$(x)';    -- filter user-defined

-- print '$(x) this is a message'
