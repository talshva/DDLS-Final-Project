import numpy as np
import random
import os
from datetime import datetime

def create_folder_for_today(index=None):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    now = datetime.now()
    folder_suffix = "" if index is None else f"_{index}"
    folder_name = now.strftime(f"%Y-%m-%d_%H-%M-%S{folder_suffix}")
    folder_path = os.path.join(script_dir, folder_name)
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
    return folder_path


def create_main_folder(BW, DW, AW, SPN):
    script_dir = os.path.dirname(os.path.abspath("__file__"))  # Use "__file__" in actual script
    folder_name = f"BW_{BW}_DW_{DW}_AW_{AW}_SPN_{SPN}"
    folder_path = os.path.join(script_dir, folder_name)
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
    return folder_path

def create_subfolder(main_folder_path, index):
    folder_path = os.path.join(main_folder_path, f"{index}")
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
    return folder_path




def user_input_or_random(prompt, choices):
    user_input = input(prompt)
    if not user_input: return random.choice(choices)
    return user_input if int(user_input) in choices else random.choice(choices)

def initialize_and_save_matrices(num_generations):

    DW_values = [8, 16, 32]
    BW_values = [16, 32, 64]
    AW_values = [16, 24, 32]
    SPN_values = [1, 2, 4]
    Biased_flag_values = [0, 1]
    NKM_values = [1,2,3,4]
    
    BW = int(user_input_or_random("Enter BW (16, 32, 64) or press 'Enter' for random: ", BW_values))
    valid_DW_values = [DW for DW in DW_values if BW >= 2 * DW and BW // DW <= 4]
    DW = int(user_input_or_random(f"Enter DW {set(valid_DW_values)} or press 'Enter' for random: ", valid_DW_values))
    AW = int(user_input_or_random("Enter AW (16, 24, 32) or press 'Enter' for random: ", AW_values))
    SPN = int(user_input_or_random("Enter SPN (1, 2, 4) or press 'Enter' for random: ", SPN_values))
    MAX_DIM = max(1, BW // DW)  # Ensure MAX_DIM is at least 1
    valid_NKM_values = [NKM for NKM in NKM_values if NKM <= MAX_DIM]
 
    
    main_folder_path = create_main_folder(BW, DW, AW, SPN)

    for i in range(num_generations):
        folder_path = create_subfolder(main_folder_path, i)
        N = random.choice(valid_NKM_values)
        K = random.choice(valid_NKM_values)
        M = random.choice(valid_NKM_values)
        SPN_SELECT = random.choice(range(SPN))

        matrices = {
        'A': np.random.randint(-2**(DW-1), 2**(DW-1), size=(N, K), dtype=np.int64), 
        'B': np.random.randint(-2**(DW-1), 2**(DW-1), size=(K, M), dtype=np.int64),
        'C': np.random.randint(-2**(DW-1), 2**(DW-1), size=(N, M), dtype=np.int64),
        'I': np.eye(M, dtype=np.int64)
        } 
        Biased_flag = random.choice(Biased_flag_values)
        res_mat = (np.dot(matrices['A'], matrices['B']) + matrices['C']) if Biased_flag else np.dot(matrices['A'], matrices['B'])
        for name, matrix in matrices.items():
            np.savetxt(os.path.join(folder_path, f"{name}_matrix.txt"), matrix, fmt='%d', delimiter=',')
        np.savetxt(os.path.join(folder_path, f"res_matrix.txt"),  res_mat , fmt='%d', delimiter=',')

        with open(os.path.join(folder_path, "parameters.txt"), 'w') as f:
            f.write(f"DW={DW}, BW={BW}, AW={AW}, SPN={SPN}, SPN_SELECT={SPN_SELECT}, Biased_flag={Biased_flag}, N={N}, K={K}, M={M}\n")

def main():

    print(
    '''

   _____ _______ _____ __  __ _    _ _     _    _  _____        
  / ____|__   __|_   _|  \/  | |  | | |   | |  | |/ ____|       
 | (___    | |    | | | \  / | |  | | |   | |  | | (___         
  \___ \   | |    | | | |\/| | |  | | |   | |  | |\___ \        
  ____) |  | |   _| |_| |  | | |__| | |___| |__| |____) |       
 |_____/ __|_|_ |_____|_|__|_|\____/|______\____/|_____/ _____  
  / ____|  ____| \ | |  ____|  __ \     /\|__   __/ __ \|  __ \ 
 | |  __| |__  |  \| | |__  | |__) |   /  \  | | | |  | | |__) |
 | | |_ |  __| | . ` |  __| |  _  /   / /\ \ | | | |  | |  _  / 
 | |__| | |____| |\  | |____| | \ \  / ____ \| | | |__| | | \ \ 
  \_____|______|_| \_|______|_|  \_\/_/    \_\_|  \____/|_|  \_\
                                                                
                                                                
                                                                                                                           
    '''
    )
    num_generations = int(input("Enter the number of generations to create: ") or "1")
    initialize_and_save_matrices(num_generations)

if __name__ == "__main__":
    main()
