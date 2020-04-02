#!/bin/bash

############## 
# TITLE
# Import from github.com/pcm-dpc/COVID-19 the CSV files as tables into an 
# Sqlite database then deploy the DB file. BASH script that requires: sqlite3, csvkit. 

############## 
# REQUIREMENTS
# sqlite - sudo apt-get install sqlite3 (Debian-like)
# csvkit - sudo pip install csvkit

############## 
# VERSION
APPNAME="CSV to DB (csv2db)"
VERSION=v0.6

############## 
# DEBUG
DEBUG=true

echo
echo "$APPNAME - $VERSION"
echo

############## 
# Setup your workspace
BASE_DIR=/tmp/dpccovid19itadb
DB_PATH=$BASE_DIR/dpc-covid19-ita_db.sqlite3
CSV_DIR=/tmp/dpccovid19itacsvs
mkdir -p $BASE_DIR
mkdir -p $CSV_DIR

################ 
# Download the files into $CSV_DIR
curl https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv \
      -o $CSV_DIR/dpc-covid19-ita-andamento-nazionale.csv
curl https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-regioni/dpc-covid19-ita-regioni.csv \
      -o $CSV_DIR/dpc-covid19-ita-regioni.csv
curl https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-province/dpc-covid19-ita-province.csv \
      -o $CSV_DIR/dpc-covid19-ita-province.csv
curl https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/note/dpc-covid19-ita-note-it.csv \
      -o $CSV_DIR/dpc-covid19-ita-note-it.csv      
curl https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/note/dpc-covid19-ita-note-en.csv \
      -o $CSV_DIR/dpc-covid19-ita-note-en.csv       
       
if $DEBUG ; then echo "CSVs downloaded!" ; fi 
 
#################
# Build the database

# First remove the existing database file, if any
rm -f $DB_PATH

## Create the andamento_nazionale table
echo "CREATE TABLE andamento_nazionale (
  data DATE, 
  stato VARCHAR, 
  ricoverati_con_sintomi INTEGER, 
  terapia_intensiva INTEGER, 
  totale_ospedalizzati INTEGER, 
  isolamento_domiciliare INTEGER, 
  totale_positivi INTEGER,
  variazione_totale_positivi INTEGER, 
  nuovi_positivi INTEGER,
  dimessi_guariti INTEGER, 
  deceduti INTEGER, 
  totale_casi INTEGER, 
  tamponi INTEGER, 
  note_it VARCHAR, 
  note_en VARCHAR
);" | sqlite3 $DB_PATH

## Create the dati_regioni table
## Create the dati_regioni table
echo "CREATE TABLE dati_regioni (
  data DATE, 
  stato VARCHAR, 
  codice_regione VARCHAR, 
  denominazione_regione VARCHAR,
  lat FLOAT, 
  long FLOAT, 
  ricoverati_con_sintomi INTEGER,
  terapia_intensiva INTEGER,
  totale_ospedalizzati INTEGER,
  isolamento_domiciliare INTEGER,
  totale_positivi INTEGER,
  variazione_totale_positivi INTEGER,  
  nuovi_positivi INTEGER,
  dimessi_guariti INTEGER,
  deceduti INTEGER,
  totale_casi INTEGER,
  tamponi INTEGER,         
  note_it VARCHAR, 
  note_en VARCHAR
);" | sqlite3 $DB_PATH

## Create the dati_province table
echo "CREATE TABLE dati_province (
  data DATE, 
  stato VARCHAR, 
  codice_regione VARCHAR, 
  denominazione_regione VARCHAR, 
  codice_provincia VARCHAR, 
  denominazione_provincia VARCHAR, 
  sigla_provincia VARCHAR, 
  lat FLOAT, 
  long FLOAT, 
  totale_casi INTEGER,
  note_it VARCHAR, 
  note_en VARCHAR
);" | sqlite3 $DB_PATH

## Create the note_it table
echo "CREATE TABLE note_it (
  codice VARCHAR,
  data DATE,
  dataset VARCHAR,
  stato VARCHAR, 
  codice_regione VARCHAR,
  regione VARCHAR,   
  codice_provincia VARCHAR, 
  provincia VARCHAR,
  sigla_provincia VARCHAR,
  tipologia_avviso VARCHAR, 
  avviso VARCHAR,  
  note VARCHAR
);" | sqlite3 $DB_PATH

## Create the note_en table
echo "CREATE TABLE note_en (
  codice VARCHAR,
  data DATE,
  dataset VARCHAR,
  stato VARCHAR, 
  codice_regione VARCHAR, 
  regione VARCHAR, 
  codice_provincia VARCHAR, 
  provincia VARCHAR,
  sigla_provincia VARCHAR,
  tipologia_avviso VARCHAR, 
  avviso VARCHAR,  
  note VARCHAR
);" | sqlite3 $DB_PATH

if $DEBUG ; then echo "Tables created!" ; fi 

#####################
# Insert the data

## Insert the andamento_nazionale data
csvsql $CSV_DIR/dpc-covid19-ita-andamento-nazionale.csv  \
    --db sqlite:///$DB_PATH --insert --no-create \
    --tables andamento_nazionale
csvsql $CSV_DIR/dpc-covid19-ita-regioni.csv  \
    --db sqlite:///$DB_PATH --insert --no-create \
    --tables dati_regioni    
csvsql $CSV_DIR/dpc-covid19-ita-province.csv  \
    --db sqlite:///$DB_PATH --insert --no-create \
    --tables dati_province
csvsql $CSV_DIR/dpc-covid19-ita-note-it.csv  \
    --db sqlite:///$DB_PATH --insert --no-create \
    --tables note_it
csvsql $CSV_DIR/dpc-covid19-ita-note-en.csv  \
    --db sqlite:///$DB_PATH --insert --no-create \
    --tables note_en
        
if $DEBUG ; then echo "Datas inserted!" ; fi 

#####################
# Deploy DB file 

## tbd


#####################
# END

## Print before exit
ls $BASE_DIR
echo
echo "All operations have been finish. Exit!"
echo

exit 0