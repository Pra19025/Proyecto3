from tkinter import *
import serial
import threading
import time
import sys


def ventana():
    
    #codigo para convertir los strings en entradas
    global pot0
    global pot1
    global pot2
  
    
    x = 0
    y = 0
    xanterior = x
    yanterior = y
    
    raiz = Tk()
    raiz.title("Cara animada")
    raiz.geometry("900x900")

    raiz.config(bg ="grey")
    canv = Canvas(raiz, width = 800, height = 800, bg = "white")
    canv.pack(fill = "both", expand="True")
    
    while True:
    
        time.sleep(0.4)
        raiz.update_idletasks()
        raiz.update()


def Comunicacion():
    pic = serial.Serial(port='COM3', baudrate=9600, parity = serial.PARITY_NONE,stopbits=serial.STOPBITS_ONE,bytesize= serial.EIGHTBITS,timeout = 0)
    pic.flushInput()
    pic.flushOutput()
        
    while True:
        pic.flushInput()
            
        time.sleep(0.4)
        pic.readline()
        read = pic.readline().decode('ascii')
        valoresPOT = read.split(",")

        pot0 = valoresPOT[0]
        pot1 = valoresPOT[1]
        pot2 = valoresPOT[2]
                
        print(read)
    return





t1 = threading.Thread(target = ventana)
t2 = threading.Thread(target = Comunicacion)

t1.start()
t2.start()

t1.join()
t2.join()
