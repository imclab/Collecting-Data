/* Load Avro jars and define shortcut */
register /me/pig/build/ivy/lib/Pig/avro-1.5.3.jar
register /me/pig/build/ivy/lib/Pig/json-simple-1.1.jar
register /me/pig/build/ivy/lib/Pig/jackson-core-asl-1.7.3.jar
register /me/pig/build/ivy/lib/Pig/jackson-mapper-asl-1.7.3.jar
register /me/pig/build/ivy/lib/Pig/joda-time-1.6.jar
define AvroStorage org.apache.pig.piggybank.storage.avro.AvroStorage();

/* MongoDB */
register /me/mongo-hadoop/mongo-2.7.3.jar
register /me/mongo-hadoop/core/target/mongo-hadoop-core-1.0.0.jar
register /me/mongo-hadoop/pig/target/mongo-hadoop-pig-1.0.0.jar
define MongoStorage com.mongodb.hadoop.pig.MongoStorage();

/* Piggybank */
register /me/pig/contrib/piggybank/java/piggybank.jar

set default_parallel 5
set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

emails = load '/me/tmp/emails_big' using AvroStorage();
emails = filter emails by message_id IS NOT NULL;

senders = foreach emails generate FLATTEN(froms) as (address, name), message_id;
tos = foreach emails generate FLATTEN(tos) as (address, name), message_id;
ccs = foreach emails generate FLATTEN(ccs) as (address, name), message_id;
bccs = foreach emails generate FLATTEN(bccs) as (address, name), message_id;
email_addresses = union senders, tos, ccs, bccs;
email_addresses = foreach email_addresses generate address as email_address, message_id;

ids_per_email = group email_addresses by email_address;
ids_per_email = group email_addresses by message_id;
