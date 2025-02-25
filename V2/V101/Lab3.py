import streamlit as st
from snowflake.snowpark.context import get_active_session
session = get_active_session()


# Sidebar
st.sidebar.title("📊 Snowflake Streamlit App")
option = st.sidebar.selectbox(
    "Choose an option",
    ["Home", "View Data", "Run Query"]
)

# Header
st.title("📈 Snowflake Streamlit Application")

if option == "Home":
    st.write("Welcome to the Snowflake-embedded Streamlit app!")

    query = """
     SELECT DISTINCT start_station_latitude as LAT, start_station_longitude as LON 
     FROM citibike.schema0.trips 
        WHERE start_station_latitude IS NOT NULL AND start_station_longitude IS NOT NULL;
    """


    df = session.sql(query).to_pandas()
    df.rename(columns={"start_station_latitude": "lat", "start_station_longitude": "lon"}, inplace=True)
    st.map(df, zoom=6)


elif option == "View Data":
    st.subheader("📂 View Sample Data")

elif option == "Run Query":
    st.subheader("🔍 Run a Custom Query")

