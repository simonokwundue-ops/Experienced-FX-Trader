import MetaTrader5 as mt5
import numpy as np
from qiskit import QuantumCircuit, transpile, QuantumRegister, ClassicalRegister
from qiskit_aer import AerSimulator
from Crypto.Hash import SHA256
import pandas as pd
from datetime import datetime, timedelta
import matplotlib
matplotlib.use('Agg')  # Use Agg backend - no GUI required
import matplotlib.pyplot as plt
import os

# Simple plot settings
plt.rcParams['figure.figsize'] = (7.5, 4.5)
plt.rcParams['figure.dpi'] = 100
plt.rcParams['savefig.dpi'] = 150
plt.rcParams['font.family'] = 'sans-serif'

# Create directory for saving images
SAVE_DIR = "quantum_trading_results"
os.makedirs(SAVE_DIR, exist_ok=True)

def initialize_mt5():
    if not mt5.initialize():
        print("MT5 initialization error")
        return False
    return True

def get_price_data(symbol="EURUSD", timeframe=mt5.TIMEFRAME_D1, n_candles=256, offset=0):
    """Retrieves price data from MT5"""
    rates = mt5.copy_rates_from_pos(symbol, timeframe, offset, n_candles)
    if rates is None:
        return None
    df = pd.DataFrame(rates)
    df['time'] = pd.to_datetime(df['time'], unit='s')
    df.set_index('time', inplace=True)
    return df

def prices_to_binary(df):
    """Converts price movements into a binary sequence"""
    binary_sequence = ""
    for i in range(1, len(df)):
        binary_sequence += "1" if df['close'][i] > df['close'][i-1] else "0"
    return binary_sequence.zfill(256)

def calculate_future_horizon(current_data, future_data, horizon=10):
    """Calculates the binary horizon of future prices"""
    future_binary = ""
    current_price = current_data['close'].iloc[-1]
    
    for price in future_data['close']:
        future_binary += "1" if price > current_price else "0"
        current_price = price
        
    return future_binary.zfill(horizon)

def calculate_trend_ratio(binary_sequence):
    """Calculates the ratio of 1/0 in a binary sequence"""
    ones = binary_sequence.count('1')
    zeros = binary_sequence.count('0')
    total = len(binary_sequence)
    return ones/total, zeros/total

def predict_horizon(quantum_counts, horizon=10):
    """Predicts the binary horizon based on the top-10 most probable states"""
    total_counts = sum(quantum_counts.values())
    # Get the top-10 states with the highest probability
    top_10_states = sorted(quantum_counts.items(), key=lambda x: x[1], reverse=True)[:10]
    predicted_binary = ""
    
    # For each position in the horizon
    for i in range(horizon):
        weighted_ones = 0
        weighted_zeros = 0
        
        # Calculate weighted probabilities for each state
        for state, count in top_10_states:
            if len(state) > i:
                weight = count / total_counts
                if state[i] == '1':
                    weighted_ones += weight
                else:
                    weighted_zeros += weight
        
        # Determine the bit based on weighted probabilities
        predicted_binary += "1" if weighted_ones > weighted_zeros else "0"
    
    return predicted_binary

def predict_trend(binary_sequence):
    """Predicts the trend based on the 1/0 ratio"""
    ones_ratio, zeros_ratio = calculate_trend_ratio(binary_sequence)
    return "BULL" if ones_ratio > 0.5 else "BEAR"

def verify_prediction(current_data, future_data):
    """Verifies the accuracy of the prediction"""
    actual_trend = "BULL" if future_data['close'].iloc[-1] > current_data['close'].iloc[-1] else "BEAR"
    return actual_trend

def sha256_to_binary(input_data):
    hasher = SHA256.new()
    hasher.update(input_data)
    return bin(int(hasher.hexdigest(), 16))[2:].zfill(256)

def qpe_dlog(a, N, num_qubits):
    qr = QuantumRegister(num_qubits + 1)
    cr = ClassicalRegister(num_qubits)
    qc = QuantumCircuit(qr, cr)
    
    for q in range(num_qubits):
        qc.h(q)
    qc.x(num_qubits)
    
    for q in range(num_qubits):
        qc.cp(2 * np.pi * (a**(2**q) % N) / N, q, num_qubits)
    
    qc.barrier()
    for i in range(num_qubits):
        qc.h(i)
        for j in range(i):
            qc.cp(-np.pi / float(2 ** (i - j)), j, i)
    
    for i in range(num_qubits // 2):
        qc.swap(i, num_qubits - 1 - i)
    
    qc.measure(range(num_qubits), range(num_qubits))
    return qc

def analyze_market_state(price_binary, num_qubits=22):
    a = 70000000
    N = 17000000
    
    qc = qpe_dlog(a, N, num_qubits)
    simulator = AerSimulator()
    compiled_circuit = transpile(qc, simulator)
    job = simulator.run(compiled_circuit, shots=3000)
    result = job.result()
    counts = result.get_counts()
    
    best_match = max(counts, key=counts.get)
    dlog_value = int(best_match, 2)
    return dlog_value, counts

def compare_horizons(real_horizon, predicted_horizon):
    """
    Compares the direction of the real and predicted horizons
    Calculates the predominant direction (more 1s or 0s) and compares them
    """
    # Count the number of 1s in the real and predicted horizons
    real_ones = real_horizon.count('1')
    pred_ones = predicted_horizon.count('1')
    
    # Determine the predominant direction
    real_trend = "BULL" if real_ones > len(real_horizon)/2 else "BEAR"
    pred_trend = "BULL" if pred_ones > len(predicted_horizon)/2 else "BEAR"
    
    return "WIN" if real_trend == pred_trend else "LOSS"

def save_histogram_plot(quantum_counts, filename="quantum_probabilities.png"):
    """Saves histogram of quantum state probabilities"""
    # Get top 10 states
    total_shots = sum(quantum_counts.values())
    sorted_states = sorted(quantum_counts.items(), key=lambda x: x[1], reverse=True)[:10]
    
    labels = [state for state, _ in sorted_states]
    values = [count/total_shots*100 for _, count in sorted_states]
    
    plt.figure(figsize=(7.5, 4))
    # Simple color palette
    colors = ['blue', 'green', 'red', 'purple', 'orange', 'brown', 'pink', 'gray', 'olive', 'cyan']
    bars = plt.bar(range(len(labels)), values, color=colors[:len(labels)])
    
    plt.xticks(range(len(labels)), labels, rotation=45, fontsize=8)
    plt.xlabel("Quantum State")
    plt.ylabel("Probability (%)")
    plt.title("Top 10 Probable Quantum States")
    plt.tight_layout()
    
    full_path = os.path.join(SAVE_DIR, filename)
    plt.savefig(full_path)
    plt.close()
    return full_path

def visualize_price_chart(historical_data, future_data, filename="price_chart.png"):
    """Visualizes price chart with forecast"""
    combined_data = pd.concat([historical_data[-30:], future_data])
    
    fig, ax = plt.subplots(figsize=(7.5, 4))
    
    # Plot historical data
    ax.plot(combined_data.index[:-len(future_data)], 
            combined_data['close'][:-len(future_data)], 
            label='Historical Data', 
            color='blue')
    
    # Plot actual future data
    ax.plot(combined_data.index[-len(future_data):], 
            combined_data['close'][-len(future_data):], 
            label='Actual Data', 
            color='green')
    
    # Add vertical line at the separation point
    ax.axvline(combined_data.index[-(len(future_data)+1)], 
              color='red', linestyle='--', label='Event Horizon')
    
    ax.set_title(f'Price Chart {combined_data.index[0].strftime("%Y-%m-%d")} - {combined_data.index[-1].strftime("%Y-%m-%d")}')
    ax.set_xlabel('Date')
    ax.set_ylabel('Close Price')
    ax.legend()
    plt.tight_layout()
    
    full_path = os.path.join(SAVE_DIR, filename)
    plt.savefig(full_path)
    plt.close()
    return full_path

def visualize_binary_comparison(real_horizon, predicted_horizon, filename="horizon_comparison.png"):
    """Visualizes comparison of real and predicted horizons"""
    fig, axes = plt.subplots(2, 1, figsize=(7.5, 4), sharex=True)
    
    # Real horizon
    for i, bit in enumerate(real_horizon):
        color = 'green' if bit == '1' else 'red'
        axes[0].bar(i, 1, color=color, edgecolor='black', linewidth=0.5)
    axes[0].set_title('Real Horizon')
    axes[0].set_yticks([])
    
    # Predicted horizon
    for i, bit in enumerate(predicted_horizon):
        color = 'green' if bit == '1' else 'red'
        axes[1].bar(i, 1, color=color, edgecolor='black', linewidth=0.5)
    axes[1].set_title('Predicted Horizon')
    axes[1].set_xlabel('Horizon Bit')
    axes[1].set_yticks([])
    
    # Legend
    from matplotlib.patches import Patch
    green_patch = Patch(color='green', label='Uptrend (1)')
    red_patch = Patch(color='red', label='Downtrend (0)')
    fig.legend(handles=[green_patch, red_patch], loc='upper right')
    
    plt.tight_layout()
    
    full_path = os.path.join(SAVE_DIR, filename)
    plt.savefig(full_path)
    plt.close()
    return full_path

def visualize_probabilities(sorted_states, horizon_length, filename="bit_probabilities.png"):
    """Visualizes probabilities for each bit in the horizon"""
    total_shots = sum(count for _, count in sorted_states)
    
    # Create probability matrix
    probabilities = []
    for i in range(horizon_length):
        weighted_ones = 0
        weighted_zeros = 0
        
        # Calculate weighted probabilities
        for state, count in sorted_states[:10]:
            if len(state) > i:
                weight = count / total_shots
                if state[i] == '1':
                    weighted_ones += weight
                else:
                    weighted_zeros += weight
        
        probabilities.append([weighted_ones, weighted_zeros])
    
    # Create a simple visualization instead of a heatmap
    fig, ax = plt.subplots(figsize=(7.5, 4))
    
    # Convert to numpy array for easier handling
    data = np.array(probabilities)
    
    # Plot as line chart
    x = range(horizon_length)
    ax.plot(x, data[:, 0], 'g-', marker='o', label='Uptrend (1)')
    ax.plot(x, data[:, 1], 'r-', marker='x', label='Downtrend (0)')
    
    # Add value labels
    for i in range(horizon_length):
        ax.text(i, data[i, 0] + 0.02, f'{data[i, 0]:.2f}', ha='center')
        ax.text(i, data[i, 1] - 0.05, f'{data[i, 1]:.2f}', ha='center')
    
    ax.set_xticks(range(horizon_length))
    ax.set_xticklabels([f'{i+1}' for i in range(horizon_length)])
    ax.set_xlabel('Horizon Bit')
    ax.set_ylabel('Probability')
    ax.set_ylim(0, 1)
    ax.set_title('Probabilities for Each Bit in Horizon')
    ax.legend()
    
    plt.tight_layout()
    
    full_path = os.path.join(SAVE_DIR, filename)
    plt.savefig(full_path)
    plt.close()
    return full_path

def analyze_from_point(timepoint_offset, n_candles=256, horizon_length=10, symbol="EURUSD"):
    """
    Analyzes the market from a given point in the past with visualization
    timepoint_offset - number of candles back from the current moment
    """
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    try:
        # Get historical data up to the event horizon point
        historical_data = get_price_data(symbol=symbol, n_candles=n_candles, offset=timepoint_offset + horizon_length)
        if historical_data is None:
            print("Failed to retrieve historical data")
            return
            
        # Get real data after the point (for prediction verification)
        future_data = get_price_data(symbol=symbol, n_candles=horizon_length, offset=timepoint_offset)
        if future_data is None:
            print("Failed to retrieve verification data")
            return
            
        # Determine the event horizon point
        horizon_point_price = historical_data['close'].iloc[-1]
        horizon_point_time = historical_data.index[-1]
        
        print(f"\n=== ANALYSIS FROM EVENT HORIZON POINT ===")
        print(f"Price at event horizon point: {horizon_point_price:.5f}")
        print(f"Time of event horizon point: {horizon_point_time}")
            
        # Convert historical prices into a binary sequence
        price_binary = prices_to_binary(historical_data)
        print("\nBinary price sequence before event horizon (last 64 bits):")
        print(price_binary[-64:])
        
        # Analyze the market state
        print("\nRunning quantum simulation...")
        market_state, quantum_counts = analyze_market_state(price_binary)
        print("Quantum simulation complete")
        
        # Visualize probability histogram
        try:
            histogram_path = save_histogram_plot(quantum_counts, f"{timestamp}_quantum_probabilities.png")
            print(f"Probability histogram saved: {histogram_path}")
        except Exception as e:
            print(f"Could not create probability histogram: {str(e)}")
        
        # Display the matrix of probable projections
        print("\nMatrix of probable projections (top-20 states):")
        print("{:<22} {:<10} {:<10}".format("State", "Frequency", "Probability"))
        print("-" * 42)
        
        total_shots = sum(quantum_counts.values())
        sorted_states = sorted(quantum_counts.items(), key=lambda x: x[1], reverse=True)
        
        for state, count in sorted_states[:20]:
            probability = count / total_shots * 100
            print("{:<22} {:<10} {:.2f}%".format(state, count, probability))
        
        # Get the real and predicted horizons
        real_horizon = calculate_future_horizon(historical_data, future_data, horizon_length)
        predicted_horizon = predict_horizon(quantum_counts, horizon_length)
        
        # Visualize horizon comparison
        try:
            comparison_path = visualize_binary_comparison(real_horizon, predicted_horizon, f"{timestamp}_horizon_comparison.png")
            print(f"Horizon comparison saved: {comparison_path}")
        except Exception as e:
            print(f"Could not create horizon comparison: {str(e)}")
            
        # Visualize bit probabilities
        try:
            probabilities_path = visualize_probabilities(sorted_states, horizon_length, f"{timestamp}_bit_probabilities.png")
            print(f"Probability chart saved: {probabilities_path}")
        except Exception as e:
            print(f"Could not create probability chart: {str(e)}")
            
        # Visualize price chart
        try:
            price_chart_path = visualize_price_chart(historical_data, future_data, f"{timestamp}_price_chart.png")
            print(f"Price chart saved: {price_chart_path}")
        except Exception as e:
            print(f"Could not create price chart: {str(e)}")
        
        print("\n=== COMPARISON OF PREDICTION WITH REALITY ===")
        print("Real horizon after the point:")
        print(real_horizon)
        print("\nPredicted horizon of future prices:")
        print(predicted_horizon)
        
        # Compare the directions of the horizons
        result = compare_horizons(real_horizon, predicted_horizon)
        horizon_accuracy = sum(a == b for a, b in zip(real_horizon, predicted_horizon)) / horizon_length
        
        print(f"\nNumber of 1s in the real horizon: {real_horizon.count('1')}/{len(real_horizon)}")
        print(f"Number of 1s in the prediction: {predicted_horizon.count('1')}/{len(predicted_horizon)}")
        print(f"Bit match accuracy: {horizon_accuracy:.2%}")
        print(f"Direction comparison result: {result}")
        
        # Analyze the probability distribution
        print("\nAnalysis of probability distribution for event horizon bits:")
        print("{:<5} {:<10} {:<10} {:<10}".format("Bit", "Prob.1", "Prob.0", "Prediction"))
        print("-" * 35)
        
        for i in range(horizon_length):
            weighted_ones = 0
            weighted_zeros = 0
            
            # Calculate weighted probabilities for the top-10 states
            for state, count in sorted_states[:10]:
                if len(state) > i:
                    weight = count / total_shots
                    if state[i] == '1':
                        weighted_ones += weight
                    else:
                        weighted_zeros += weight
                        
            predicted_bit = "1" if weighted_ones > weighted_zeros else "0"
            print("{:<5} {:<10.2%} {:<10.2%} {:<10}".format(
                i+1, weighted_ones, weighted_zeros, predicted_bit
            ))
            
    except Exception as e:
        print(f"Error during analysis: {str(e)}")

def main():
    if not initialize_mt5():
        return
    
    try:
        print("\n=== QUANTUM TRADING ANALYZER ===")
        print("This tool analyzes financial markets using quantum computing")
        
        # Request symbol
        symbol = input("Enter symbol for analysis (default EURUSD): ") or "EURUSD"
        
        # Request event horizon point
        offset = int(input("Enter event horizon point offset (number of candles back from current moment): "))
        horizon_length = int(input("Enter event horizon length (default 10): ") or "10")
        
        # Perform analysis from the given point
        analyze_from_point(offset, horizon_length=horizon_length, symbol=symbol)
        
        print(f"\nAnalysis completed. All visualizations saved in folder: {os.path.abspath(SAVE_DIR)}")
        
    except Exception as e:
        print(f"Error in main function: {str(e)}")
    finally:
        mt5.shutdown()

if __name__ == "__main__":
    main()
