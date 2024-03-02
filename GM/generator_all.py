import numpy as np
import random
import os
from datetime import datetime

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



# Modified function to generate all combinations and save matrices along with parameters
def initialize_and_save_matrices_all_combinations(num_generations):
    DW_values = [8, 16, 32]
    BW_values = [16, 32, 64]
    AW_values = [16, 24, 32]
    SPN_values = [1, 2, 4]
    Biased_flag_values = [0, 1]

    for BW in BW_values:
        for DW in DW_values:
            if BW < 2 * DW or BW // DW > 4:
                continue  # Ensure valid combinations
            for AW in AW_values:
                for SPN in SPN_values:
                    main_folder_path = create_main_folder(BW, DW, AW, SPN)
                    MAX_DIM = max(1, BW // DW)
                    valid_NKM_values = range(1, MAX_DIM + 1)
                
                    for i in range(num_generations):
                                folder_path = create_subfolder(main_folder_path, i)
                                SPN_SELECT = random.choice(range(SPN))
                                N = random.choice(valid_NKM_values)
                                K = random.choice(valid_NKM_values)
                                M = random.choice(valid_NKM_values)
                                Biased_flag = random.choice(Biased_flag_values)

            
                                matrices = {
                                    'A': np.random.randint(-2**(DW-1), 2**(DW-1), size=(N, K), dtype=np.int64),
                                    'B': np.random.randint(-2**(DW-1), 2**(DW-1), size=(K, M), dtype=np.int64),
                                    'C': np.random.randint(-2**(DW-1), 2**(DW-1), size=(N, M), dtype=np.int64),
                                    'I': np.eye(M, dtype=np.int64)
                                }
                                res_mat = np.dot(matrices['A'], matrices['B']) + matrices['C']*Biased_flag

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
    num_generations = int(input("Enter the number of test cases to generate: ") or "1")
    initialize_and_save_matrices_all_combinations(num_generations)

if __name__ == "__main__":
    main()
