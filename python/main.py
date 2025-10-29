#!/usr/bin/env python3
"""
APEX Arbitrage System - ML Inference Server
FastAPI server for machine learning model inference
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any
import uvicorn
import numpy as np
import os
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s]: %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI(title="APEX ML Inference Server")

class PredictionRequest(BaseModel):
    features: List[float]
    opportunity_id: str

class PredictionResponse(BaseModel):
    score: float
    confidence: float
    approved: bool
    opportunity_id: str

# Simple rule-based model (fallback when ONNX model not available)
class SimplePredictorModel:
    def predict(self, features: np.ndarray) -> tuple:
        """
        Simple rule-based prediction
        Features: [profit, profitUSD, gasEstimate, inputAmount, outputAmount, pathLength, dexCount, freshness]
        """
        if len(features) < 8:
            return 0.5, 0.5
        
        profit_usd = features[1]
        gas_estimate = features[2]
        
        # Calculate a simple score based on profit and gas
        score = min(1.0, max(0.0, profit_usd / 20.0))  # Score based on profit up to $20
        
        # Adjust for gas costs
        if gas_estimate > 500000:
            score *= 0.8
        
        # Calculate confidence
        confidence = 0.6 if profit_usd > 5 else 0.4
        
        return score, confidence

# Initialize model
predictor = SimplePredictorModel()

@app.get("/")
async def root():
    return {
        "service": "APEX ML Inference Server",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "model": "simple_predictor",
        "version": "1.0.0"
    }

@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    """
    Predict arbitrage opportunity score
    """
    try:
        logger.info(f"Prediction request for opportunity: {request.opportunity_id}")
        
        # Convert features to numpy array
        features = np.array(request.features)
        
        # Get prediction
        score, confidence = predictor.predict(features)
        
        # Determine approval (threshold: 0.6)
        approved = score >= 0.6
        
        response = PredictionResponse(
            score=float(score),
            confidence=float(confidence),
            approved=approved,
            opportunity_id=request.opportunity_id
        )
        
        logger.info(f"Prediction result - Score: {score:.3f}, Approved: {approved}")
        
        return response
        
    except Exception as e:
        logger.error(f"Prediction error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

@app.post("/batch_predict")
async def batch_predict(requests: List[PredictionRequest]):
    """
    Batch prediction for multiple opportunities
    """
    try:
        results = []
        for req in requests:
            features = np.array(req.features)
            score, confidence = predictor.predict(features)
            approved = score >= 0.6
            
            results.append(PredictionResponse(
                score=float(score),
                confidence=float(confidence),
                approved=approved,
                opportunity_id=req.opportunity_id
            ))
        
        return results
        
    except Exception as e:
        logger.error(f"Batch prediction error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Batch prediction failed: {str(e)}")

def main():
    """Start the ML inference server"""
    host = os.getenv("ML_SERVER_HOST", "0.0.0.0")
    port = int(os.getenv("ML_SERVER_PORT", "8000"))
    
    logger.info(f"Starting ML Inference Server on {host}:{port}")
    
    uvicorn.run(
        app,
        host=host,
        port=port,
        log_level="info"
    )

if __name__ == "__main__":
    main()
