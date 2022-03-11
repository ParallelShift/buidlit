const abbi = []


const connect = new Promise((res, rej) => {    // 
	if (typeof window.ethereum == "undefined") {
		rej("install metamask!");
	}

	window.ethereum.request({ method: "eth_requestAccounts"});
	console.log(res);
	// let web3 = new Web3(window.ethereum);
	// let contract = new web3.eth.Contract(abbi, "contract address");
	// contract.methods
	// 	.totalSupply()
	// 	.call({ from: "a wallet address from code or hardcode" })
	// 	.then((supply) => {
	// 		contract.methods.GetLoc()
	// 			.call({ from: "a wallet address from code or hardcode" }).then((location) => {
	// 				console.log( data)
	// 				res({ supply: supply, location: location })
	// 			});
	// 	});  //lots of connecty type stuff here reading data to play with in the calling file
})

export default connect;