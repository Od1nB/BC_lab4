import React, { useState, useEffect } from 'react';
import logo from './logo.svg';
import { Contract } from 'web3-eth-contract';
import json from './contracts/Betting.json';
import useWeb3 from './hooks/web3';
import './App.css';
import AccountsTable from './components/AccountsTable';

const App: React.VFC = () => {
  const { isLoading, isWeb3, web3, accounts } = useWeb3();
  const [instance, setInstance] = useState<Contract>();

  const abi: any = json.abi;

  useEffect(() => {
    (async() => {
      if(web3 !== null) {
        // const networkId = await web3.eth.net.getId();
        const deployedNetwork = json.networks["5777"];
        const instance = new web3.eth.Contract(
          abi,
          deployedNetwork.address);
        setInstance(instance);
        console.log(instance?.methods)
        await instance?.methods.chooseOracle(accounts[0]).send({from: accounts[0]} );
        // console.log(await instance?.methods.isOracle("0x22d491Bde2303f2f43325b2108D26f1eAbA1e32b"));
      }
    })();
  }, [isLoading, isWeb3, abi, web3]);

  function handleSubmit(){
    
    console.log("man");
  }

  // {accounts.map((acc) => {
  //   <AccountField accs={acc} />
  // })}
return (
  <div className="App">
    { isLoading ? <div>Loading Web3, accounts, and contract...</div>
    : isWeb3 ? 
      <>
        <h1>REACT ;)!</h1>
        {/* <img src={logo} /> */}
        <AccountsTable accounts={accounts}/>
        <form onSubmit={handleSubmit}>
          <input type="text" placeholder="OracleAdress"></input>
          <input type="submit" value="Set Oracle"></input>
        </form>
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