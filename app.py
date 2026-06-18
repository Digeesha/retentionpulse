```python
import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import numpy as np
from typing import Dict, List, Tuple, Optional
import sys
from pathlib import Path

# Add src to path for imports
sys.path.append(str(Path(__file__).parent))

from src.database import DatabaseManager
from src.analytics import AttritionAnalyzer
from src.config import DB_CONFIG, APP_CONFIG


def init_session_state() -> None:
    """Initialize session state variables for caching data."""
    if 'data_loaded' not in st.session_state:
        st.session_state.data_loaded = False
    if 'df' not in st.session_state:
        st.session_state.df = None
    if 'analyzer' not in st.session_state:
        st.session_state.analyzer = None


@st.cache_data
def load_data() -> pd.DataFrame:
    """Load employee data from PostgreSQL database.
    
    Returns:
        DataFrame containing employee records with features and attrition status
    """
    try:
        db = DatabaseManager(DB_CONFIG)
        df = db.fetch_employee_data()
        db.close()
        return df
    except Exception as e:
        st.error(f"Database connection failed: {str(e)}")
        st.info("Attempting to load from backup CSV file...")
        try:
            df = pd.read_csv('data/employees.csv')
            return df
        except FileNotFoundError:
            st.error("Backup data file not found. Please ensure database is running or data file exists.")
            return pd.DataFrame()


def create_kpi_cards(df: pd.DataFrame, analyzer: AttritionAnalyzer) -> None:
    """Display key performance indicators in card layout.
    
    Args:
        df: Employee dataframe
        analyzer: Configured AttritionAnalyzer instance
    """
    col1, col2, col3, col4 = st.columns(4)
    
    total_employees = len(df)
    attrition_count = df['attrition'].sum()
    attrition_rate = (attrition_count / total_employees) * 100
    avg_tenure = df['years_at_company'].mean()
    high_risk_count = len(analyzer.get_high_risk_employees(threshold=0.7))
    
    with col1:
        st.metric(
            label="Total Employees",
            value=f"{total_employees:,}",
            delta=None
        )
    
    with col2:
        st.metric(
            label="Attrition Rate",
            value=f"{attrition_rate:.1f}%",
            delta=f"-{attrition_count} employees",
            delta_color="inverse"
        )
    
    with col3:
        st.metric(
            label="Avg Tenure",
            value=f"{avg_tenure:.1f} yrs",
            delta=None
        )
    
    with col4:
        st.metric(
            label="High Risk Employees",
            value=f"{high_risk_count}",
            delta=f"{(high_risk_count/total_employees)*100:.1f}% of workforce",
            delta_color="inverse"
        )


def plot_attrition_by_department(df: pd.DataFrame) -> go.Figure:
    """Create grouped bar chart showing attrition by department.
    
    Args:
        df: Employee dataframe
        
    Returns:
        Plotly figure object
    """
    dept_attrition = df.groupby(['department', 'attrition']).size().reset_index(name='count')
    dept_attrition['attrition'] = dept_attrition['attrition'].map({0: 'Retained', 1: 'Attrited'})
    
    fig = px.bar(
        dept_attrition,
        x='department',
        y='count',
        color='attrition',
        barmode='group',
        title='Attrition by Department',
        color_discrete_map={'Retained': '#2ecc71', 'Attrited': '#e74c3c'},
        labels={'count': 'Number of Employees', 'department': 'Department'}
    )
    
    fig.update_layout(
        plot_bgcolor='rgba(0,0,0,0)',
        paper_bgcolor='rgba(0,0,0,0)',
        font=dict(size=12),
        height=400,
        legend=dict(title='Status', orientation='h', yanchor='bottom', y=1.02, xanchor='right', x=1)
    )
    
    return fig


def plot_satisfaction_distribution(df: pd.DataFrame) -> go.Figure:
    """Create violin plot showing job satisfaction distribution by attrition status.
    
    Args:
        df: Employee dataframe
        
    Returns:
        Plotly figure object
    """
    df_plot = df.copy()
    df_plot['status'] = df_plot['attrition'].map({0: 'Retained', 1: 'Attrited'})
    
    fig = go.Figure()
    
    for status, color in [('Retained', '#2ecc71'), ('Attrited', '#e74c3c')]:
        data = df_plot[df_plot['status'] == status]['job_satisfaction']
        fig.add_trace(go.Violin(
            y=data,
            name=status,
            box_visible=True,
            meanline_visible=True,
            fillcolor=color,
            opacity=0.6,
            line_color=color
        ))
    
    fig.update_layout(
        title='Job Satisfaction Distribution by Attrition Status',
        yaxis_title='Job Satisfaction (1-4)',
        plot_bgcolor='rgba(0,0,0,0)',
        paper_bgcolor='rgba(0,0,0,0)',
        height=400,
        showlegend=True
    )
    
    return fig


def plot_tenure_salary_scatter(df: pd.DataFrame, analyzer: AttritionAnalyzer) -> go.Figure:
    """Create scatter plot of tenure vs salary with attrition risk overlay.
    
    Args:
        df: Employee dataframe
        analyzer: Configured AttritionAnalyzer instance
        
    Returns:
        Plotly figure object
    """
    df_plot = df.copy()
    
    # Get risk predictions
    risk_scores = analyzer.predict_attrition_risk()
    df_plot['risk_score'] = risk_scores
    df_plot['status'] = df_plot['attrition'].map({0: 'Retained', 1: 'Attrited'})
    
    fig = px.scatter(
        df_plot,
        x='years_at_company',
        y='monthly_income',
        color='risk_score',
        size='job_satisfaction',
        hover_data=['department', 'job_role', 'status'],
        title='Employee Tenure vs Income (Risk Analysis)',
        color_continuous_scale='RdYlGn_r',
        labels={
            'years_at_company': 'Years at Company',
            'monthly_income': 'Monthly Income ($)',
            'risk_score': 'Attrition Risk'
        }
    )
    
    fig.update_layout(
        plot_bgcolor='rgba(0,0,0,0)',
        paper_bgcolor='rgba(0,0,0,0)',
        height=500
    )
    
    return fig


def plot_feature_importance(analyzer: AttritionAnalyzer) -> go.Figure:
    """Display top factors contributing to attrition.
    
    Args:
        analyzer: Configured AttritionAnalyzer instance
        
    Returns:
        Plotly figure object
    """
    importance_df = analyzer.get_feature_importance()
    top_features = importance_df.head(10)
    
    fig = px.bar(
        top_features,
        x='importance',
        y='feature',
        orientation='h',
        title='Top 10 Attrition Risk Factors',
        labels={'importance': 'Importance Score', 'feature': 'Factor'},
        color='importance',
        color_continuous_scale='Reds'
    )
    
    fig.update_layout(
        plot_bgcolor='rgba(0,0,0,0)',
        paper_bgcolor='rgba(0,0,0,0)',
        height=500,
        showlegend=False,
        yaxis={'categoryorder': 'total ascending'}
    )
    
    return fig


def plot_work_life_balance_impact(df: pd.DataFrame) -> go.Figure:
    """Analyze work-life balance impact on attrition.
    
    Args:
        df: Employee dataframe
        
    Returns:
        Plotly figure object
    """
    wlb_data = df.groupby('work_life_balance').agg({
        'attrition': ['sum', 'count']
    }).reset_index()
    
    wlb_data.columns = ['work_life_balance', 'attrited', 'total']
    wlb_data['attrition_rate'] = (wlb_data['attrited'] / wlb_data['total']) * 100
    wlb_data['retained_rate'] = 100 - wlb_data['attrition_rate']
    
    fig = go.Figure()
    
    fig.add_trace(go.Bar(
        x=wlb_data['work_life_balance'],
        y=wlb_data['retained_rate'],
        name='Retained',
        marker_color='#2ecc71'
    ))
    
    fig.add_trace(go.Bar(
        x=wlb_data['work_life_balance'],
        y=wlb_data['attrition_rate'],
        name='Attrited',
        marker_color='#e74c3c'
    ))
    
    fig.update_layout(
        title='Work-Life Balance Impact on Retention',
        xaxis_title='Work-Life Balance Rating (1-4)',
        yaxis_title='Percentage (%)',
        barmode='stack',
        plot_bgcolor='rgba(0,0,0,0)',
        paper_bgcolor='rgba(0,0,0,0)',
        height=400,
        legend=dict(orientation='h', yanchor='bottom', y=1.02, xanchor='right', x=1)
    )
    
    return fig


def plot_overtime_analysis(df: pd.DataFrame) -> go.Figure:
    """Analyze overtime impact across departments.
    
    Args:
        df: Employee dataframe
        
    Returns:
        Plotly figure object
    """
    overtime_dept = df.groupby(['department', 'overtime']).agg({
        'attrition': 'mean'
    }).reset_index()
    overtime_dept['attrition_rate'] = overtime_dept['attrition'] * 100
    overtime_dept['overtime'] = overtime_dept['overtime'].map({0: 'No Overtime', 1: 'Overtime'})
    
    fig = px.bar(
        overtime_dept,
        x='department',
        y='attrition_rate',
        color='overtime',
        barmode='group',
        title='Overtime Impact on Attrition by Department',
        labels={'attrition_rate': 'Attrition Rate (%)', 'department': 'Department'},
        color_discrete_map={'No Overtime': '#3498db', 'Overtime': '#e67e22'}
    )
    
    fig.update_layout(
        plot_bgcolor='rgba(0,0,0,0)',
        paper_bgcolor='rgba(0,0,0,0)',
        height=400
    )
    
    return fig


def plot_cohort_