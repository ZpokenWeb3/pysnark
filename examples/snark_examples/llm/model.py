import pysnark.runtime
from pysnark.runtime import PrivVal, snark, PubVal, LinComb
from sklearn.linear_model import LinearRegression
import numpy as np
import math

@snark
def train_model():
    # Create dataset
    X = np.array([[1], [2], [3], [4], [5]])
    y = np.array([2, 4, 6, 8, 10])
    # Train model
    model = LinearRegression()
    model.fit(X, y)
    coef = model.coef_[0]
    intercept = model.intercept_
    print(f"Model trained: coef={coef}, intercept={intercept}")
    return coef, intercept

@snark
def prove_prediction(coef, intercept, x_input, expected_output):
    # Set private data & public parameters
    X_secret = PrivVal(int(x_input.val())) 
    Y_secret = PrivVal(int(expected_output.val()))
    coef_pub = PubVal(int(coef.val()))
    intercept_pub = PubVal(int(intercept.val()))
    # Calculate prediction inside SNARK
    prediction = coef_pub * X_secret + intercept_pub
    # Chack if the prediction is correct
    prediction.assert_eq(Y_secret)
    print(f"Proved prediction for input {x_input}")

coef, intercept = train_model()
x_test = 6
expected_y = coef * x_test + intercept
prove_prediction(coef, intercept, x_test, expected_y)
