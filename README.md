# CardMetrics

# Project Background:

The company CardMetrics Inc. operates in the financial services industry, specializing in credit card issuance and payment processing. It employs a hybrid B2C and B2B model, serving individual customers and corporate clients with tailored credit solutions. The company generates revenue through a subscription-based and transactional model, earning from interest on revolving credit, processing fees, and customer engagement programs.

Key business metrics include credit utilization rates (CUR), transaction volume trends, customer retention, and revenue growth. These metrics enable the company to evaluate card performance, customer financial health, and market competitiveness.

The analysis was presented in three interactive dashboards tailored for stakeholders to gain insights into performance and identify growth opportunities:
1. Cards Dashboard: Focuses on credit card performance, including CUR trends by income and card brand, expiring card monitoring, and segmentation of credit limits.
2. Transactions Dashboard: Highlights revenue and transactional growth, comparing performance by month, card type, and card brand, with visual insights into revenue generation and customer spending patterns.
3. Customer Dashboard: Examines customer demographics and financial health metrics, including debt-to-income ratios, credit score distributions, income levels, and gender-based breakdowns, while tracking new customer acquisition trends.

Insights and recommendations are provided on the following key areas:

- Credit utilization and limit trends
- Revenue and Transactions growth
- Customer demographics and financial health
- Product performance and engagement
- Insights into customer retention and card expiration

# Data Structure & Initial Checks

### Data cleaning:

Before importing the dataset into MySQL Workbench, I performed the following data cleaning steps:
- Removed the "$" sign from columns like per_capita_income and yearly_income to ensure numerical consistency.
- Formatted date columns into the correct format for proper storage and querying.
- Dropped irrelevant columns such as card_on_dark_web to maintain dataset relevance.
- Imputed "0" in ZIP records where transactions were conducted online.
- Replaced empty values in the errors column with NULL to maintain data integrity.
  
The company’s main database consists of three primary tables:
1. Users_data – Stores customer demographic and financial information, including age, gender, income, debt, and credit scores.
2. Cards_data – Contains details of issued credit cards, such as card brand, type, credit limit, expiration date, and security features.
3. Transactions_data – Records transaction history, including amounts, merchant details, and payment methods (chip usage, location).
Each table is linked via client_id, allowing cross-analysis of customer demographics, spending behavior, and credit health metrics.



