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

elif option == "View Data":
    st.subheader("📂 View Sample Data")


elif option == "Run Query":
    st.subheader("🔍 Run a Custom Query")

