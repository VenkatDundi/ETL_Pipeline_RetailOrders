import kaggle
import os
import pandas as pd
import numpy as np
import sqlalchemy  as sa
import pyodbc

from zipfile import ZipFile


# Extract data from the kaggle api {Downloaded api key token and saved in ~/.kaggle}
def extract(ds):
    
    kaggle.api.authenticate()
    # [unzip = false] can also be used as a parameter
    kaggle.api.dataset_download_files(ds, path='.')             

    # Check if the file format is Zip and extract
    for i in os.listdir("."):
        if i.endswith("zip"):
            with ZipFile(i, 'r') as zip1:
                zip1.extractall()                # Extracts the csv files in the same directory
        else:
            downloaded_file = i
    

def transform():

    # Consider only 1 csv file is available upon extraction from zip file
    for i in os.listdir("."):
        # Validate if the file type is csv and then transform
        if i.endswith("csv"):
            
            df = pd.read_csv(i)
            # Convert column headers to lower case and replace the space with _
            df.columns = [i.lower().replace(" ", "_") for i in df.columns]

            # Replace the unnecessary values of a field to nan
            df["ship_mode"] = df["ship_mode"].replace(["Not Available", "unknown"], pd.NA)
            df["ship_mode"] = df["ship_mode"].replace(pd.NA, np.nan)
            
            # Calculate Discount
            df["discount"] = df["list_price"] * df["discount_percent"] / 100
            # Calculate Sale Price
            df["sale_price"] = df["list_price"] - df["discount"]
            #Calculate Profit ---> returns
            df["profit"] = df["sale_price"] - df["cost_price"]
            df.rename(columns={"profit" : "returns"}, inplace=True)
            #Calculate returns % rounded by 2 decimals
            df["returns%"] = round((df["returns"] * 100) / df["cost_price"], 2)

            #Dropping unnecessary columns
            df.drop(columns=['cost_price', 'list_price', 'discount_percent'], inplace=True)    
    
    return df


def load(dataframe):

    # Establish to SQL Server with Windows Authentication- ServerName InstanceName(If Available) DatabaseName
    engine = sa.create_engine("mssql://Venkat/ETL?driver=ODBC+Driver+17+for+SQL+Server")
    conn = engine.connect()
    #print(conn)

    # Using 'append' as the table has been created in the database (ETL), which saves some storage space for fields compared to using 'replace' parameter for "if_exists"

    result = dataframe.to_sql('df_orders', con=conn, index=False, if_exists='append')

    conn.close()

    return f"\nResult of the Load Operation is: {result}"



try:                 # Make sure to request api using Author/Dataset; There may be chances of Access Denied due to continuous request hit to API

    Extracted = extract(input("Provide the Author/Datset from URL: "))                # ankitbansal06/retail-orders
    Transformed = transform()
    Load = load(Transformed)

except(Exception) as e:
    print(e)

else:
    print(Transformed)
    print(Load)

finally:
    print("End of the Connection!")
