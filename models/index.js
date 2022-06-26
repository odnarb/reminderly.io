const { Sequelize, Model, DataTypes } = require('sequelize')

class Customer extends Model {}
class Company extends Model {}

module.exports = (sequelize) => {

    let module = {};

    module.Customer = Customer.init({
        name: DataTypes.STRING,
        company_id: DataTypes.INTEGER,
        details: DataTypes.JSON,
        active: DataTypes.INTEGER,
        updated_at: {
          type: DataTypes.DATE,
          defaultValue: DataTypes.NOW
        },
        created_at: {
          type: DataTypes.DATE,
          defaultValue: DataTypes.NOW
        }
    }, { sequelize, freezeTableName: true, modelName: 'customer', timestamps: false })

    module.Company = Company.init({
        name: DataTypes.STRING,
        alias: DataTypes.STRING,
        details: DataTypes.JSON,
        active: DataTypes.INTEGER,
        updated_at: {
          type: DataTypes.DATE,
          defaultValue: DataTypes.NOW
        },
        created_at: {
          type: DataTypes.DATE,
          defaultValue: DataTypes.NOW
        }
    }, { sequelize, freezeTableName: true, modelName: 'company', timestamps: false })

    return module
};