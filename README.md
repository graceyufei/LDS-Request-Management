# LDS Request Management

### Example Data
The following example data is for three institutions. Five data files are included, all in TSV format:

- `Dataset.tsv`
- `DUA.tsv`
- `log_query.tsv`
- `PI_request.tsv`
- `PI.tsv`



### Deploying and Setting Up Smart Contracts on Remix IDE
#### Prerequisites
- Solidity version >= 0.8.4
- A web browser (Chrome, Firefox, etc.)

#### 1. Open Remix IDE
Go to the [Remix IDE website](https://remix.ethereum.org/).

#### 2. Upload Contracts
1. In the left sidebar, click on the `File Explorer` icon.
2. Click on the `Upload files` button to upload all 6 smart contracts.
    - `Connector.sol`
    - `DataConcierge.sol`
    - `DateTime.sol`
    - `Institution.sol`
    - `Log.sol`
    - `PIManagement.sol`

#### 3. Compile Contracts
1. Click on the `Solidity Compiler` icon in the left sidebar.
2. Click on the `Compile xxx.sol` button for each smart contract.

#### 4. Deploy Contracts

1. Click on the `Deploy & Run Transactions` icon in the left sidebar.
2. Make sure `Environment` is set to `Remix VM` for local testing. 
3. Under `Deployed Contracts`, select a contract from the dropdown and click the `Deploy` button.
   - Deploy `Connector`, `DateTime`, and `Log` once.
   - For each institution, follow these steps:
    1. Deploy `DataConcierge` and `PIManagement`.
    2. Copy the addresses of the deployed `DataConcierge` and `PIManagement` contracts.
    3. When deploying `Institution`, enter the name of the institution and the addresses of the deployed `DataConcierge` and `PIManagement` contracts as constructor parameters.

#### 5. Configure Connector Contract
1. Select the deployed `Connector` contract from the `Deployed Contracts` section.
2. Insert the deployed `DateTime` address into the deployed `Connector` contract by calling the `insertDateTime(DateTime address)` function.
3. Insert the deployed `Log` address into the deployed `Connector` contract by calling the `insertLog(Log address)` function.
4. Insert all deployed `Institution` addresses into the deployed `Connector` contract by calling the `insertInstitution(Institution address)` function with each `Institution` contract address.

#### 6. Interact with Contracts

1. After deployment and configuration, your contract will appear under the `Deployed Contracts` section.
2. You can interact with your contract functions (e.g., `insertDataset`) directly from the Remix interface.