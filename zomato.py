import streamlit as st
import pandas as pd
import plotly.express as px
# --------------------------------------------------
# CONFIG
# --------------------------------------------------
st.set_page_config(page_title="Zomato Dashboard", page_icon="🍽", layout="wide")
ZOMATO_RED = "#E23744"
# --------------------------------------------------
# BACKGROUND (ZOMATO STYLE)
# --------------------------------------------------
st.markdown(
    """
    <style>
    .stApp {
        background-image:
        linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
        url("https://images.unsplash.com/photo-1504674900247-0877df9cc836");
        background-size: cover;
        background-position: center;
    }
    section[data-testid="stSidebar"] {
        background-color: rgba(0,0,0,0.85);
    }
    div[data-testid="stMetric"] {
        background-color: rgba(0,0,0,0.6);
        padding: 15px;
        border-radius: 12px;
    }
    h1,h2,h3,h4,h5,h6,p,label {
        color: white !important;
    }
    </style>
    """,
    unsafe_allow_html=True
)
# --------------------------------------------------
# LOAD DATA
# --------------------------------------------------
@st.cache_data
def load_data():
    df = pd.read_excel("Zomato Dataset.xlsx")
    df.columns = df.columns.str.strip()
    return df
df = load_data()
# --------------------------------------------------
# TITLE
# --------------------------------------------------
st.markdown("<h1 style='text-align:center;'>🍽 Zomato Data Analysis Dashboard</h1>", unsafe_allow_html=True)
st.markdown("<p style='text-align:center;'>Interactive restaurant analytics & insights</p>", unsafe_allow_html=True)
st.markdown("---")
# --------------------------------------------------
# SIDEBAR FILTERS
# --------------------------------------------------
st.sidebar.header("🔍 Filters")
city_list = sorted(df["City"].dropna().unique())
city_list.insert(0, "All")
city = st.sidebar.selectbox("Select City", city_list)
min_rating = st.sidebar.slider("Minimum Rating", 0.0, 5.0, 3.0)
if city == "All":
    filtered_df = df[df["Rating"] >= min_rating]
else:
    filtered_df = df[(df["City"] == city) & (df["Rating"] >= min_rating)]
# --------------------------------------------------
# KPI METRICS
# --------------------------------------------------
col1, col2, col3 = st.columns(3)
col1.metric("Total Restaurants", filtered_df.shape[0])
col2.metric("Average Rating", round(filtered_df["Rating"].mean(), 2))
if not filtered_df.empty and not filtered_df["Currency"].mode().empty:
    currency = filtered_df["Currency"].mode().iloc[0]
else:
    currency = ""
avg_cost = int(filtered_df["Average_Cost_for_two"].mean()) if not filtered_df.empty else 0
col3.metric("Avg Cost for Two", f"{currency} {avg_cost}")
st.markdown("---")
# --------------------------------------------------
# 🧠 AUTO-GENERATED INSIGHTS
# --------------------------------------------------
st.subheader("🧠 Key Insights")
if not filtered_df.empty:
    top_city = filtered_df["City"].mode().iloc[0]
    best_rating = filtered_df["Rating"].max()
    top_rest = filtered_df.loc[filtered_df["Rating"].idxmax()]["RestaurantName"]
    st.markdown(f"""
    - ⭐ **Highest rated restaurant:** {top_rest} ({best_rating})
    - 🏙 **Most active city:** {top_city}
    - 💰 **Average cost for two:** {currency} {avg_cost}
    """)
else:
    st.warning("No data available for selected filters.")
st.markdown("---")
# --------------------------------------------------
# 📊 RATING DISTRIBUTION (HISTOGRAM)
# --------------------------------------------------
st.subheader("📊 Rating Distribution")
fig_rating = px.histogram(
    filtered_df,
    x="Rating",
    nbins=10,
    color_discrete_sequence=[ZOMATO_RED]
)
st.plotly_chart(fig_rating, use_container_width=True)
# --------------------------------------------------
# 📊 BAR CHART – TOP CUISINES
# --------------------------------------------------
st.subheader("🍜 Top 10 Cuisines")
top_cuisines = (
    filtered_df["Cuisines"]
    .dropna()
    .str.split(",")
    .explode()
    .value_counts()
    .head(10)
    .reset_index()
)
top_cuisines.columns = ["Cuisine", "Count"]
fig_bar = px.bar(
    top_cuisines,
    x="Cuisine",
    y="Count",
    text="Count",
    color_discrete_sequence=[ZOMATO_RED]
)
st.plotly_chart(fig_bar, use_container_width=True)
# --------------------------------------------------
# 🥧 PIE CHART – PRICE RANGE
# --------------------------------------------------
st.subheader("🥧 Price Range Distribution")
price_dist = filtered_df["Price_range"].value_counts().reset_index()
price_dist.columns = ["Price Range", "Count"]
fig_pie = px.pie(
    price_dist,
    names="Price Range",
    values="Count",
    color_discrete_sequence=px.colors.sequential.Reds
)
st.plotly_chart(fig_pie, use_container_width=True)
# --------------------------------------------------
# 📈 SCATTER – COST vs RATING
# --------------------------------------------------
st.subheader("💰 Cost vs Rating")
fig_scatter = px.scatter(
    filtered_df,
    x="Average_Cost_for_two",
    y="Rating",
    hover_name="RestaurantName",
    color_discrete_sequence=[ZOMATO_RED],
    opacity=0.6
)
st.plotly_chart(fig_scatter, use_container_width=True)
# --------------------------------------------------
# 🗺 MAP VISUALIZATION
# --------------------------------------------------
st.subheader("🗺 Restaurant Locations")
map_df = filtered_df.dropna(subset=["Latitude", "Longitude"])
fig_map = px.scatter_mapbox(
    map_df,
    lat="Latitude",
    lon="Longitude",
    hover_name="RestaurantName",
    hover_data=["City", "Rating"],
    zoom=10,
    height=500,
    color_discrete_sequence=[ZOMATO_RED]
)
fig_map.update_layout(
    mapbox_style="open-street-map",
    margin={"r":0,"t":0,"l":0,"b":0}
)
st.plotly_chart(fig_map, use_container_width=True)
# --------------------------------------------------
# RAW DATA
# --------------------------------------------------
with st.expander("📄 View Filtered Data"):
    st.dataframe(filtered_df)