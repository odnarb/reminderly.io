module.exports = (globals) => {
    return (error, req, res, next) => {
        try {
            globals.logger.debug(`ERROR HANDLER: res: ${res.statusCode} :: xhr?: ${req.xhr} :: error: `, error);

            return res.json({ status: "ERROR", error: error.toString() });
        } catch(e) {
            return res.status(500).json({ status: "500 Internal Server Error"});
        }
    } //return()
};
