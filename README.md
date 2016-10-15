# DMA 2016 Analytics Challenge

## Top 5 Solution
Together, [Josh Jacquet](https://www.linkedin.com/in/josh-jacquet-3360a13b) and [Will Johnson](https://www.linkedin.com/in/willjjohnson), developed a two-layer model approach and placed in the top 5 of the [DMA's annual Analytics Challenge](https://thedma.org/membership/member-groups-communities/analytics-community/dma-analytic-challenge/).  The source uploaded includes data exploration, data visualization, exploratory models, hyperparameter analysis, parallel processing, and finally model combinations.

## DMA Analytics Challenge Prompt

Welcome to the 2016 DMA Analytic Challenge sponsored by EY. We are glad you have decided to participate. Below is various
information you will need to develop and submit your solution.

### 1. Business Overview:
Company  A  is  one  of  the  world’s  largest  players  in  the  online  peer­to­peer  lending  business  which  has  been  instrumental  in
transforming the consumer and small business credit marketplace. The business model is as follows: the borrowers get access
to lower interest rate loans through a fast and easy online or mobile interface, and investors provide the capital to enable many of
the loans in exchange for earning interest. Since Company A uses little or no branch infrastructure, they can transfer the cost
savings to the borrowers in form of lower interest rates and get attractive returns for the investors.
 
Company A is planning to use data analytics by leveraging the information on the existing loans that were extended to various
consumers and small business and identifying the characteristics associated with the most highly profitable customers. For this
purpose  of  this  exercise,  Company  A  has  provided  data  on  768K  loans  that  were  issued  in  the  past  and  the  associated
information captured, including:
 
* Customer attributes at the time of application
* Information around loan performance (last payment, outstanding balance, interest rate, etc.)
* Loan status (Current, Delinquent, Charged off, etc.)
* Some bureau attributes that were captured from the bureau data (past trade line information, etc.)
 
For Company A to increase its return on investments on a marketing campaign, it is important to understand the attributes that
can  help  identify  the  most  profitable  customers  in  order  to  improve  its  solicitation  as  well  as  underwriting  processes  for  new
loans. From an analytical standpoint, there are 2 key aspects to an effective marketing campaign; a solicitation response model
that  helps  to  increase  the  acquisition  rate  and  a  high  value  customer  identification  model  that  helps  the  company  get  higher
lifetime value from their customers. The focus of this problem is towards identifying the attributes of high value customers which
can then be supplemented with a response rate model to enhance the ROI for a marketing investment.

### 2. Analytics Challenge:
 
The dataset for training the model would consist of approx. 768K  loans which the participants would use to build their model to
predict the estimated profitability of the loans. This consists of loans that existed on Company A’s books as of a point in time and
has  loans  that  are  currently  performing  (i.e.  in  repayment),  historically  paid  off  and  historically  charged  off  loans.  The  target
variable for the participants is the $ profitability associated  with  a  loan,  which  is  defined  as  the  gross  $  value  margin  that  was
made on that loan.
 
Subsequently, the validation dataset would have approx. 85K loans for which the participants will have to generate the prediction
of  the  profitability  for.  The  final  evaluation  for  the  competition  will  be  defined  by  the  Root  Mean  Squared  Error  (RMSE)  of  the
predicted profitability values.

### 3. Datasets:
Go to the following link to retrieve the modeling data sets, data dictionary and an example version of the submission:

| Training dataset | https://www.dropbox.com/s/omkuesx1mu29a4r/EY_DMA_Analytics_2016_Training_Data0822.csv?dl=0 |
| Test dataset | https://www.dropbox.com/s/sdznzo4dgi3wcaz/EY_DMA_Analytics_2016_Testing_Data_0822.csv?dl=0 |
| Data Dictionary | https://www.dropbox.com/s/8fpl1b24fs4yafn/EY_DMA_DataDictionary.xlsx?dl=0
Example |

### 4. Data FAQs:
 
What is the size of the dataset?
* The training dataset has in total 768,168 rows and 44 columns.
* The validation dataset has in total 84,910 rows and 42 columns.

What do negative values mean for profitability?
* The profitability $ amount takes negative value if the loans were charged off and positive value if it was paid in full OR was charged off after the payments made exceeded the principal amount.

Are there any data quality issues in the dataset?
* In case of any data quality issues please use your best judgment for treatment and interpretation of such values

What does each column represent?
* Refer to the data dictionary for description on all the variables

What is inside the training dataset?
* The training dataset has information on current loans on book, paid off loans and some charged off loans.

Does the test data include only active loans?
* The test dataset has information on paid off and charged off loans where the final profitability was realized
