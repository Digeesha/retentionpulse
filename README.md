# 📊 RetentionPulse

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Stars](https://img.shields.io/github/stars/yourusername/retentionpulse?style=social)
![Python Version](https://img.shields.io/badge/python-3.8%2B-blue)
![Streamlit](https://img.shields.io/badge/streamlit-1.28%2B-FF4B4B)

**Employee turnover prediction dashboard with actionable retention insights**

RetentionPulse is an interactive analytics platform that transforms employee data into strategic retention insights. Built to showcase end-to-end data science capabilities, it combines PostgreSQL data modeling, statistical analysis, and executive-ready visualizations to predict attrition risk and identify key retention drivers. Perfect for HR analytics teams, data scientists, and anyone interested in people analytics.

---

## ✨ Features

- 🎯 **Predictive Attrition Scoring** - Machine learning-powered risk assessment for each employee
- 📈 **Interactive Dashboards** - Real-time filtering and drill-down capabilities with Plotly visualizations
- 🔍 **Root Cause Analysis** - Identify top retention drivers across departments, tenure, and compensation
- 💡 **Actionable Insights** - Executive-ready recommendations based on statistical analysis
- 🗄️ **Robust Data Pipeline** - PostgreSQL integration with efficient pandas transformations
- 📊 **Multi-dimensional Analytics** - Explore attrition patterns by role, salary, satisfaction, and performance
- 🎨 **Professional UI/UX** - Clean, intuitive Streamlit interface designed for business stakeholders

---

## 🛠️ Tech Stack

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Streamlit](https://img.shields.io/badge/Streamlit-FF4B4B?style=for-the-badge&logo=streamlit&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-150458?style=for-the-badge&logo=pandas&logoColor=white)
![Plotly](https://img.shields.io/badge/Plotly-3F4F75?style=for-the-badge&logo=plotly&logoColor=white)

- **Frontend**: Streamlit
- **Data Processing**: pandas, NumPy
- **Visualization**: Plotly, Matplotlib
- **Database**: PostgreSQL
- **Analytics**: scikit-learn, SciPy

---

## 🚀 Getting Started

### Prerequisites

Before running RetentionPulse, ensure you have the following installed:

- Python 3.8 or higher
- PostgreSQL 12 or higher
- pip (Python package manager)
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/retentionpulse.git
cd retentionpulse
```

2. **Create a virtual environment**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Set up PostgreSQL database**
```bash
# Create database
createdb retentionpulse

# Run migration scripts
psql -d retentionpulse -f database/schema.sql
psql -d retentionpulse -f database/seed_data.sql
```

5. **Configure environment variables**
```bash
cp .env.example .env
# Edit .env with your database credentials
```

6. **Run the application**
```bash
streamlit run app.py
```

The dashboard will be available at `http://localhost:8501`

---

## 📖 Usage

### Basic Dashboard Navigation

Launch the application and explore different analytics views:

```bash
streamlit run app.py
```

### Programmatic Data Access

Use the analytics module to generate custom insights:

```python
from src.analytics import AttritionPredictor
from src.data_loader import load_employee_data

# Load employee data
df = load_employee_data()

# Initialize predictor
predictor = AttritionPredictor()
predictor.fit(df)

# Get risk scores for all employees
risk_scores = predictor.predict_risk(df)

# Identify high-risk employees
high_risk = df[risk_scores > 0.7]
print(f"High-risk employees: {len(high_risk)}")
```

### Custom Analytics Pipeline

```python
from src.pipeline import RetentionPipeline

# Initialize pipeline
pipeline = RetentionPipeline(db_conn_string="postgresql://user:pass@localhost/retentionpulse")

# Run full analysis
results = pipeline.run_analysis(
    filters={'department': 'Engineering'},
    metrics=['attrition_rate', 'avg_satisfaction', 'retention_drivers']
)

# Export insights
pipeline.export_report(results, format='pdf')
```

### Generate Sample Data

```python
from src.data_generator import generate_employee_data

# Create synthetic dataset
df = generate_employee_data(n_employees=1000, attrition_rate=0.16)
df.to_csv('data/employees.csv', index=False)
```

---

## 🏗️ Project Architecture

```
retentionpulse/
│
├── app.py                      # Main Streamlit application
├── requirements.txt            # Python dependencies
├── .env.example               # Environment variables template
├── README.md                  # Project documentation
│
├── src/
│   ├── __init__.py
│   ├── analytics.py           # Attrition prediction models
│   ├── data_loader.py         # Database connection & data loading
│   ├── data_generator.py      # Synthetic data generation
│   ├── visualizations.py      # Plotly chart functions
│   └── pipeline.py            # End-to-end analytics pipeline
│
├── database/
│   ├── schema.sql             # Database schema definition
│   ├── seed_data.sql          # Sample data for testing
│   └── migrations/            # Database migration scripts
│
├── data/
│   ├── raw/                   # Raw employee data files
│   └── processed/             # Cleaned & transformed data
│
├── notebooks/
│   ├── exploratory_analysis.ipynb
│   └── model_development.ipynb
│
├── tests/
│   ├── test_analytics.py
│   ├── test_data_loader.py
│   └── test_visualizations.py
│
└── assets/
    ├── screenshots/           # Dashboard screenshots
    └── docs/                  # Additional documentation
```

---

## 🔑 Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=retentionpulse
DB_USER=your_username
DB_PASSWORD=your_password

# Application Settings
APP_ENV=development
DEBUG_MODE=True

# Analytics Parameters
ATTRITION_THRESHOLD=0.7
MIN_SAMPLE_SIZE=30

# Optional: External API Keys
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
EMAIL_USER=your_email@example.com
EMAIL_PASSWORD=your_app_password
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Development Guidelines

- Follow PEP 8 style guidelines
- Add unit tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR

```bash
# Run tests
pytest tests/

# Check code style
flake8 src/

# Format code
black src/
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 RetentionPulse

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

<p align="center">
  Built with ❤️ and Alviora AI
</p>