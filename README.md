# LDS Request Management

## Example Data
The following example data is for three institutions. Five data files are included, all in TSV format:

- `Dataset.tsv`
- `DUA.tsv`
- `log_query.tsv`
- `PI_request.tsv`
- `PI.tsv`



## Deploying and Setting Up Smart Contracts on Remix IDE
### Prerequisites
- Solidity version >= 0.8.4
- A web browser (Chrome, Firefox, etc.)

### 1. Open Remix IDE
Go to the [Remix IDE website](https://remix.ethereum.org/).

### 2. Upload Contracts
1. In the left sidebar, click on the `File Explorer` icon.
2. Click on the `Upload files` button to upload all 6 smart contracts.
    - `Connector.sol`
    - `DataConcierge.sol`
    - `DateTime.sol`
    - `Institution.sol`
    - `Log.sol`
    - `PIManagement.sol`

### 3. Compile Contracts
1. Click on the `Solidity Compiler` icon in the left sidebar.
2. Click on the `Compile xxx.sol` button for each smart contract.

### 4. Deploy Contracts

1. Click on the `Deploy & Run Transactions` icon in the left sidebar.
2. Make sure `Environment` is set to `Remix VM` for local testing. 
3. Under `Deployed Contracts`, select a contract from the dropdown and click the `Deploy` button.
   - Deploy `Connector`, `DateTime`, and `Log` once.
   - For each institution, follow these steps:
    1. Deploy `DataConcierge` and `PIManagement`.
    2. Copy the addresses of the deployed `DataConcierge` and `PIManagement` contracts.
    3. When deploying `Institution`, enter the name of the institution and the addresses of the deployed `DataConcierge` and `PIManagement` contracts as constructor parameters.

### 5. Configure Connector Contract
1. Select the deployed `Connector` contract from the `Deployed Contracts` section.
2. Insert the deployed `DateTime` address into the deployed `Connector` contract by calling the `insertDateTime(DateTime address)` function.
3. Insert the deployed `Log` address into the deployed `Connector` contract by calling the `insertLog(Log address)` function.
4. Insert all deployed `Institution` addresses into the deployed `Connector` contract by calling the `insertInstitution(Institution address)` function with each `Institution` contract address.

### 6. Interact with Contracts

1. After deployment and configuration, your contract will appear under the `Deployed Contracts` section.
2. You can interact with your contract functions (e.g., `insertDataset`) directly from the Remix interface.

## Metadata Import
Before processing any data requests, it's crucial to import the necessary metadata into the system. This ensures that all researcher information, dataset information, certifications, and data use agreements are recorded and managed for accurate data request results.

### Data Concierge Metadata with `DataConcierge` smart contract. 
The `DataConcierge` smart contract manages metadata related to datasets and data use agreements (DUAs). Follow these steps to import the necessary dataset information:
1. **Insert Dataset Information with `insertDataset()`**

    This function is used to add new dataset information into the system, including details such as the dataset name, data sharing link, owner researcher, certificate requirement, and DUA number. 
    - Example: `insertDataset('Data Set 11', 'https://dataset_repository.com/data_set_11', 'janedoe@inst1.edu', ['Biomedical Data Only Research','Biomedical Informatics Responsible Conduct of Research'], 'DUADS11')`

2. **Insert Data Use Agreement Information with `insertDUA()`**
   
    This function allows the addition of new DUAs associated with the datasets. It includes details such as the DUA identifier and researchers who have signed the agreement.
    - Example: `insertDUA

### Researcher/PI Metadata Import under an Institution's `PIManagement` Smart Contract
The `PIManagement` smart contract is responsible for handling the metadata associated with researchers or Principal Investigators (PIs) from an institution. Follow the steps below to import the required metadata:
1. **Insert Researcher Information with `insertPI()`**
   
    This function is used to add a new researcher's information into the system, including the researcher's name and email.
    - Example: `insertPI('Jane Doe', 'janedoe@inst1.edu')`
2. **Insert Certificate with `insertNewCertificate()`**

    This function allows the addition of new certificates for researchers.Certificates can include certificate/program name and expiration date.
    - Example: `insertNewCertificate('janedoe@inst1.edu', 'Biomedical Data Only Research', '05/29/2025')`
3. **Insert Signed Data Use Agreement with `signDUA()`**
   
    This function records the signing of a Data Use Agreement (DUA) by a researcher. The user needs to specify the origin institute of the dataset and the DUA number corresponding to the dataset.
    - Example: `signDUA('janedoe@inst1.edu', 'Institution 2', 'DUA01')`

## Researcher Data Request

Before performing a data request, ensure that all dataset and researcher information has been uploaded to the blockchain. Researchers should use the `requestData()` function from their institution's `PIManagement` smart contract with their email, dataset's institution, dataset name, and Unix timepoint.

- Example: `requestData('janedoe@inst1', 'Inst 2', 'Data Set 22', 1668747266)`

This function handles the data request process and returns one of five possible responses:

1. **No Matching Dataset**

    This response indicates that the requested dataset does not exist or does not match any datasets stored in the institution.

2. **DUA Required**

    This response indicates that the researcher must sign a Data Use Agreement (DUA) before accessing the requested dataset.

3. **Certificate Missing**

    This response indicates that the researcher is missing the necessary certificates required to access the dataset.

4. **Certificate Expired**

    This response indicates that the researcher has a certificate, but it has expired and needs to be renewed to access the dataset.

5. **Data Sharing Link**

    This response provides a link to access the requested dataset. It indicates that all requirements (DUA, certificates) have been met and the researcher can proceed to access the data.

Researchers should ensure they have all necessary agreements and certifications in place to streamline the data request process. By following the correct procedure and meeting all requirements, researchers can efficiently access the data they need for their projects.

