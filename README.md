![horse](https://github.com/towhidrazu/Famous_Paintings-Data_analysis_with_SQL/blob/main/horse_and_boats.jpg)
# Famous_Paintings-Data_analysis_with_SQL
## Answering several questions using SQL queries from Paintaings data

***Little background: Recently, I visited the Museum of Natural Sciences at the University of Saskatchewan. On the same day, after returning home, I opened YouTube and came across a video from the famous TechTFQ channel. The video focused on paintings and museum data analysis using SQL. The dataset included information about various paintings displayed in museums worldwide. The analysis involved answering a handful of questions using SQL queries. Given my recent museum visit, I found a connection to the content and decided to recreate the project, intending to add it to my portfolio.***


**Dataset is taken from this link: https://www.kaggle.com/datasets/mexwell/famous-paintings**

In this project, under the folder of 'datasets' we have 8 numbers of CSV files. We have to import those CSV files into our postgreSQL. To do that easily we will use python programming language. We will use 'pandas' and 'sqlalchemy' library of python. Pandas is a very popular python library used for working with data sets. It has functions for analyzing, cleaning, exploring, and manipulating data. SQLAlchemy is the Python SQL toolkit and Object Relational Mapper that gives application developers the full power and flexibility of SQL. 

Now will install the following python libraries through terminal one by one
```
pip install pandas

pip install sqlalchemy

--additionally if required he have to install following 2 libraries

pip install pyarrow

pip install psycopg2

```

Then we will create a database in postgreSQL named 'paintaings' where we will load our CSV files.

Now on Visual Studio code we will run the following codes to create 8 new tables with all their data from 8 CSV files under paintaings database.

```
import pandas as pandas
from sqlalchemy import create_engine

conn_string = 'postgresql://postgres:password@localhost/paintings'
db = create_engine(conn_string)
conn = db.connect()

files = ['artist', 'canvas_size', 'image_link', 'museum_hours', 'museum', 'product_size', 'subject', 'work']

for file in files:
    df = pd.read_csv(f'F:\paintaings\Dataset\{file}.csv')
    df.to_sql(file, con=conn, if_exists='replace', index=False)
```

Now all 8 CSV files are loaded into our paintaings database of PostgreSQL and ready to be used with SQL queries.

