# ETL Pipeline - Retail Orders  

## Project Overview  
This project focuses on building an ETL (Extract, Transform, Load) pipeline that extracts retail sales data from a Kaggle API, transforms it using Pandas, and loads it into SQL Server. The project also involves querying the database to explore insights into retail sales data. Additionally, Power BI is used to visualize the extracted data by connecting to the SQL Server database. Query parameters in Power BI allow filtering and interaction with the stored data.  

---

## Tech Stack  
- **Python** (for data extraction and transformation)  
- **Pandas** (for data processing)  
- **SQL Server** (for data storage and querying)  
- **Power BI** (for visualization)  

---

## Flow Diagram
Please find below, the flow of actions which can be performed by a user in the application.

![Flow Diagram](https://github.com/VenkatDundi/ETL_Pipeline_RetailOrders/blob/main/snapshots/Structure.jpg)

## Learning Outcomes  

### **Data Extraction & Transformation**  
1. Accessing data via an API.  
2. Handling compressed files (unzipping methods).  
3. Performing various Pandas operations:  
   - Column transformations  
   - Checking value counts (`value_counts()`)  
   - Filtering dataframes  
   - Removing/updating columns and performing calculations to create new dataframes  

### **Data Loading & Validation**  
4. Connecting to SQL Server (Windows Authentication).  
5. Creating and loading tables in SQL Server.  
6. Validating records after data load.  
7. Performing necessary transformations in SQL if missed during the earlier steps.  

### **SQL Querying Techniques**  
8. Writing optimized SQL queries using:  
   - Subqueries  
   - Common Table Expressions (CTEs)  
   - Window functions  

### **Power BI Visualization**  
9. Connecting Power BI to SQL Server.  
10. Using query parameters in Power BI to filter and control the amount of data pulled into the model.  
11. Leveraging stored procedures in Power BI to retrieve data while abstracting query details.  
12. Utilizing Power BI components to create interactive dashboards and visualizations.  

---

## SQL Transformations & Key Learnings  

### **Handling Zero Division Errors**  
- When calculating `returns%` in Pandas, the **zero division error** was not accounted for.  
- Solution: An SQL `UPDATE` statement was used to set `returns%` to **0** when both `sale_price = 0` and `discount = 0`.  

### **Discount Percentage Calculation**  
- The `discount%` column was initially removed in Pandas but later needed in SQL.  
- Solution: A **CASE statement** was used to handle division by zero while recalculating `discount%`.  

### **Data Type Handling & Formatting**  
- Used `CAST()` to round calculated values to a specific precision.  

### **Pivoting Data for Analysis**  
- Used **PIVOT tables** in SQL to transform row-based data into a column-based summary (for month-over-month and year-over-year comparisons).  

---

## Installation & Setup  

### **Prerequisites**  
Ensure you have the following installed:  
- Python (>=3.8)  
- Pandas  
- SQL Server  
- Power BI Desktop  


### **Steps to Run the Project**  
1. Clone the repository:
  
   ```sh
   git clone https://github.com/your-username/etl-retail-orders.git
   cd etl-retail-orders
   ```

2. Configure Kaggle API Access

    Ensure you have a Kaggle account and generate an API key.
    Save the API key as a JSON file at the following location:

    ```
    \.kaggle\kaggle.json
    ```

3. Set Up the SQL Server Database

    Create a database in SQL Server.
    Use the provided schema to create the necessary tables.

4. Run the ETL Pipeline

    Execute the ETL script by running:
    ```
    python scripts/ETL.py
    ```

    This script will:
    Connect to the Kaggle API and fetch data.
    Extract and unzip the dataset.
    Perform necessary transformations using Pandas.
    Load the processed data into SQL Server using Windows Authentication.
    
    Before executing script make : 
    ```
    - Linux/macOS:
      mkdir -p ~/.kaggle
      mv ~/Downloads/kaggle.json ~/.kaggle/
      chmod 600 ~/.kaggle/kaggle.json  # Secure the file
   
   - Windows (Command Prompt):
      mkdir %USERPROFILE%\.kaggle
      move C:\path\to\kaggle.json %USERPROFILE%\.kaggle\
    ```
  

6. Query the Database

    Utilize the provided SQL scripts and stored procedures to analyze the data and extract insights.

7. Visualize Data in Power BI

    Open the Power BI report (.pbix file)
    Update the SQL Server connection settings to match your database configuration. [Provide Server, Database Name]
    Refresh the data to generate interactive reports and visualizations
    
> [!Tip]
> Use Query Parameters to retrieve specific records from tables, and make use of Power Automate to perform various interesting actions - For Example, Sending an email with interesting insights.

## **Findings & Insights**  

1. **Regional Sales Contribution**  
   - The **West region** generated the highest sales, totaling **$699,858.60**.  

2. **State-wise Sales Performance**  
   - **California** recorded the highest sales among all states, contributing **$441,657**.  
   - **North Dakota** reported the lowest sales, with a total of **$877.70**.  

3. **City-wise Sales Trends**  
   - **New York City** led in sales with **$247,205.70**.  
   - **Layton** recorded **$0** in sales.  
   - There were **8 cities** with zero sales contribution.  

4. **Customer Segment Analysis**  
   - The **Consumer segment** emerged as the top-performing customer segment in terms of product sales.  

5. **Order Distribution by Region**  
   - Customers from the **West region** placed the highest number of orders, totaling **3,203**.  

6. **Shipping Mode Analysis**  
   - **6 orders** were recorded without a specified **Shipment Mode**, accounting for **0.13%** of total orders.  
   - **Standard Class** shipment mode had the highest order count, contributing **59% of total sales**.  

7. **Product Returns & Growth Trends**  
   - The highest **positive return rate** for certain products was **47%**, while the highest **negative return rate** was **-5%**.  
   - There was a **Year-on-Year (YoY) sales growth of 2.25%** from **2022 to 2023**.  
   - The **Supplies sub-category** exhibited the highest growth percentage in sales from **2022 to 2023**.  


## **Snapshots**

![Power BI Report Home](https://github.com/VenkatDundi/ETL_Pipeline_RetailOrders/blob/main/snapshots/report_home.png)   


![Power BI Report Home](https://github.com/VenkatDundi/ETL_Pipeline_RetailOrders/blob/main/snapshots/stored_procedure.png)   

## **Advancements**

1. Identify more interesting insights making use of SQL querying
2. Utilize Power BI visuals to present the retrieved data
3. Make use of automate functionalities available in Power BI effectively
4. Automate the flow  
