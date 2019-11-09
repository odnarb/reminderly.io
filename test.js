let reminderly = require('./reminderly.js');
let cleanNoun = "Company";


let db_config = {
    host     : 'localhost',
    user     : 'reminderly',
    password : 'Rem!nDerly123!$',
    database : 'reminderly'
};

let company = new reminderly[cleanNoun](db_config);

// `name` VARCHAR(255) NOT NULL DEFAULT '',
// `alias` VARCHAR(255) NOT NULL DEFAULT '',
// `details` json NOT NULL,
// `active` INT NOT NULL,

let opts = {
	name: "MHGR-Atlanta Dental",
	alias: "MHGR-01",
	details: { 
		a:1,
		b:123,
		c:321,
		test: [ 
			{ obj1: true },
			{ obj2: 321 },
			{ obj3: "this is a test"}
		]
	},
	active: true // this should not be save.. because we're disallowing companies to be active on first save.. one must go into company details and set them to active
};

company.create(opts,function(err, res){
	console.log("err: ", err);
	console.log("res: ", res);

});

