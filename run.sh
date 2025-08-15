conda activate wise  
cd /mnt/mmlabworkspace/WorkSpaces/ngaptb/HumanActionMimic/TruyXuatThongTin/wise


# Download data
mkdir wise-projects/
mkdir wise-data/
cd /mnt/mmlabworkspace/WorkSpaces/ngaptb/HumanActionMimic/TruyXuatThongTin/wise/wise-data
curl -sLO "https://thor.robots.ox.ac.uk/wise/assets/test/Kinetics-6c.tar.gz"
tar -zxvf Kinetics-6c.tar.gz -C .


# apt-get update && apt-get install -y sqlite3
# bash tests/test-wikimedia-commons-25.sh  temp/


# extract features
cd /mnt/mmlabworkspace/WorkSpaces/ngaptb/HumanActionMimic/TruyXuatThongTin/wise

python extract-features.py wise-data/Kinetics-6c --project-dir wise-projects/Kinetics-6c


# create metadata
python media-metadata.py import \
  --metadata-id "Kinetics-6c" \
  --from-csv wise-data/Kinetics-6c/metadata.csv \
  --metadata-type "media" \
  --project-dir wise-projects/Kinetics-6c


# create index in database
python create-index.py \
  --project-dir wise-projects/Kinetics-6c/ \
  --fts-config wise-projects/Kinetics-6c/fts_config.json 
  


# Test server to directly search
python serve.py --project-dir wise-projects/Kinetics-6c/

# Evaluation 
mkdir wise-test/

python search.py \
  --queries-from wise-data/Kinetics-6c/sample_queries.csv \
  --in video \
  --topk 10 \
  --index-type IndexFlatIP \
  --result-format csv \
  --save-to-file wise-test/results.csv \
  --project-dir wise-projects/Kinetics-6c/


# Exhaustive
python search.py --queries-from wise-data/Kinetics-6c/sample_queries.csv \
  --in video --topk 100 --index-type IndexFlatIP \
  --result-format csv --save-to-file wise-test/exhaustive.csv \
  --project-dir wise-projects/Kinetics-6c/


# ANN
python search.py --queries-from wise-data/Kinetics-6c/sample_queries.csv \
  --in video --topk 100 --index-type IndexIVFFlat \
  --result-format csv --save-to-file wise-test/ann.csv \
  --project-dir wise-projects/Kinetics-6c/

conda activate wise

# Download new dataset
cd wise-data/
curl -sLO "https://thor.robots.ox.ac.uk/wise/assets/test/wikimedia-commons-25.zip"
unzip wikimedia-commons-25.zip -d .

cd /mnt/mmlabworkspace/WorkSpaces/ngaptb/HumanActionMimic/TruyXuatThongTin/wise

# extract features
cd wise-projects/
mkdir Wikimedia-Commons-25
python extract-features.py wise-data/wikimedia-commons-25 --project-dir wise-projects/Wikimedia-Commons-25

# create metadata
python media-metadata.py import --metadata-id "wikimedia-commons-25" --from-csv wise-data/wikimedia-commons-25/media-metadata.csv --metadata-type "media" --project-dir wise-projects/Wikimedia-Commons-25

# create index in database
# python create-index.py --project-dir wise-projects/Wikimedia-Commons-25/ --fts-config wise-projects/Wikimedia-Commons-25/fts_config.json

python search.py --queries-from wise-data/wikimedia-commons-25/sample_queries.csv --in video --topk 100 --index-type IndexFlatIP --result-format csv --save-to-file wise-test/exhaustive-wikimedia-commons-25.csv --project-dir wise-projects/Wikimedia-Commons-25

python search.py --queries-from wise-data/wikimedia-commons-25/sample_queries.csv --in video --topk 100 --index-type IndexIVFFlat --result-format csv --save-to-file wise-test/ann-wikimedia-commons-25.csv --project-dir wise-projects/Wikimedia-Commons-25