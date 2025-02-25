import streamlit as st
from snowflake.snowpark.context import get_active_session
session = get_active_session()
import matplotlib.pyplot as plt
import pandas as pd

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

    # CHART 1
    st.subheader("🟢 User Type Distribution")
    query = """
    SELECT usertype, COUNT(*) as COUNT 
    FROM citibike.schema0.trips 
    GROUP BY usertype;
    """

    df = session.sql(query).to_pandas() 
    fig, ax = plt.subplots()
    ax.pie(df["COUNT"], labels=df["USERTYPE"],  startangle=90)
    ax.axis("equal")
    st.pyplot(fig)

    # CHART TWO
    st.subheader("🏆 Most Popular Start Stations")
    query = """
    SELECT start_station_name, COUNT(*) as trip_count 
    FROM citibike.schema0.trips 
    GROUP BY start_station_name 
    ORDER BY trip_count DESC 
    LIMIT 10;
    """

    df = session.sql(query).to_pandas()

    fig, ax = plt.subplots()
    ax.barh(df["START_STATION_NAME"], df["TRIP_COUNT"])
    ax.set_xlabel("Number of Trips")
    ax.set_ylabel("Start Station")
    ax.set_title("Top 10 Most Popular Start Stations")
    st.pyplot(fig)

    # CHART THREE
    st.subheader("⏱️ Avg Trip Duration by User Type")
    query = """
    SELECT usertype, AVG(tripduration) as avg_duration 
    FROM citibike.schema0.trips 
    GROUP BY usertype;
    """
    
    df = session.sql(query).to_pandas()
    st.write(df)

    fig, ax = plt.subplots()
    ax.bar(df["USERTYPE"], df["AVG_DURATION"], color=["blue", "green"])
    ax.set_ylabel("Avg Trip Duration (seconds)")
    ax.set_title("Average Trip Duration by User Type")
    st.pyplot(fig)


elif option == "Run Query":
    st.subheader("🔍 Run a Custom Query")

    # Sidebar Filters
    with st.sidebar:
        st.subheader("🔧 Query Filters")

        # User Type Selection
        user_type = st.selectbox("Select User Type:", ["All", "Subscriber", "Customer"])

        # Trip Duration Filter
        min_duration, max_duration = st.slider("Trip Duration (seconds):", 0, 3600, (60, 900))

        # Fetch Unique Locations (Start Stations) from Snowflake
        location_query = """
        SELECT DISTINCT start_station_name FROM citibike.schema0.trips
        WHERE start_station_name IS NOT NULL ORDER BY start_station_name;
        """
        location_df = session.sql(location_query).to_pandas()
        location_list = location_df["START_STATION_NAME"].tolist()  # Add "All" option

        # Location Dropdown
        selected_location = st.selectbox("Select Start Station (Optional):", location_list)

    # Constructing SQL Query Dynamically
    query = f"""
    SELECT starttime, stoptime, start_station_name, end_station_name, tripduration, usertype, birth_year
    FROM citibike.schema0.trips
    WHERE tripduration BETWEEN {min_duration} AND {max_duration}
    """

    if user_type != "All":
        query += f" AND usertype = '{user_type}'"


    query += f" AND start_station_name = '{selected_location}'"

    # Execute the Query
    data = session.sql(query).to_pandas()
    df = pd.DataFrame(data)

    # Display Results
    st.write(f"**Showing {len(df)} results based on filters:**")
    st.dataframe(df)
