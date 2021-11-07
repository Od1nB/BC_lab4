import React, { useState, useEffect } from 'react';
import { Contract } from 'web3-eth-contract';
import json from './contracts/Betting.json';
import useWeb3 from './hooks/web3';
import './App.css';
import AccountsTable from './components/AccountsTable';
import MuiAlert, { AlertProps } from '@mui/material/Alert';

const App: React.VFC = () => {
  const { isLoading, isWeb3, web3, accounts } = useWeb3();
  const [instance, setInstance] = useState<Contract>();

  const abi: any = json.abi;

  useEffect(() => {
    (async () => {
      if (web3 !== null) {
        // const networkId = await web3.eth.net.getId();
        const deployedNetwork = json.networks["5777"];
        const instance = new web3.eth.Contract(
          abi,
          deployedNetwork.address);
        setInstance(instance);
      }
    })();
  }, [isLoading, isWeb3, abi, web3, accounts]);

  const Alert = React.forwardRef<HTMLDivElement, AlertProps>(function Alert(
    props,
    ref,
  ) {
    return <MuiAlert elevation={6} ref={ref} variant="filled" {...props} />;
  });

  function handleSubmit() {

    console.log("man");
  }

  async function getOutcomes() {
    const resp = await instance?.methods.getOutcomes().send({ from: accounts[1] })
      .once("transactionHash", (txHash: any) => {
        console.log('Transaction', txHash, 'sent.');
        <Alert severity="info">Transaction {txHash} sent.</Alert>
      })
      .once("receipt", () => {
        console.log('Transaction complete!');
        <Alert severity="success">Transaction complete!</Alert>
      })
      .once("data", (data: any) => {
        console.log("Got This data:")
        console.log(data);
      })
      .on("error", (err: any) => {
        console.log('Transaction failed', err);
        <Alert severity="error">Transaction failed: {err}</Alert>
      })
  }

  // {accounts.map((acc) => {
  //   <AccountField accs={acc} />
  // })}
  return (
    <div className="App">
      {isLoading ? <div>Loading Web3, accounts, and contract...</div>
        : isWeb3 ?
          <>
            <h1>REACT ;)!</h1>
            {/* <img src={logo} /> */}
            <AccountsTable accounts={accounts} />
            <form onSubmit={handleSubmit}>
              <input type="text" placeholder="OracleAdress"></input>
              <input type="submit" value="Set Oracle"></input>
            </form>
            <button onClick={getOutcomes}>Outcomes</button>
            {/* <button onClick={runExample} >click</button> */}
          </>
          : <div>
            <p>none web3</p>
          </div>
      }
    </div>
  );
}

export default App;