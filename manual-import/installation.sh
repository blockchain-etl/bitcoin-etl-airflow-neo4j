gcloud compute firewall-rules create allow-neo4j-bolt-https \
   --allow tcp:7473,tcp:7687 \
   --source-ranges 0.0.0.0/0 \
   --target-tags neo4j
