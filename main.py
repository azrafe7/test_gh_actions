import os

if __name__ == '__main__':
    print("Hello from main.py")
    #print(f"abspath: {os.path.abspath(__file__)}")
    print("abspath: {0}".format(os.path.abspath(__file__)))