// Node.js functions for API calls based on LearningAPICalls folder
// Each function reads the corresponding JSON file and returns its contents

const axios = require('axios');

const BASE_URL = 'http://localhost:5000';

async function getIngredients() {
    const res = await axios.get(`${BASE_URL}/ingredients`);
    return res.data;
}

async function getInstructions() {
    const res = await axios.get(`${BASE_URL}/instructions`);
    return res.data;
}

async function getNutrition() {
    const res = await axios.get(`${BASE_URL}/nutrition`);
    return res.data;
}

async function getPrice() {
    const res = await axios.get(`${BASE_URL}/price`);
    return res.data;
}

module.exports = {
    getIngredients,
    getInstructions,
    getNutrition,
    getPrice
};
