let sender = require('./lambda/sender.js');

let result = sender.handler({
	Records: [
		{ contact_method: 1 },
		{ contact_method: 1 },
		{ contact_method: 1 },
		{ contact_method: 1 }
	]
});
console.log("result: ", result);
