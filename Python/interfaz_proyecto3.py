from tkinter import *
import serial
import threading
import time
import sys


def ventana():
    
    #codigo para convertir los strings en entradas
    global potx
    global poty
    potx = 120
    poty = 120
    global x
    global y
    global xanterior
    global yanterior
    
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


def Comunicacion():
    pic = serial.Serial(port='COM3', baudrate=9600, parity = serial.PARITY_NONE,stopbits=serial.STOPBITS_ONE,bytesize= serial.EIGHTBITS,timeout = 0)
    pic.flushInput()
    pic.flushOutput()
        
    while True:
        pic.flushInput()
            
        time.sleep(0.4)
        pic.readline()
        read = pic.readline().decode('ascii')
        print("lectura",read)
        valoresxy = read.split(",")

        global potx
        global poty
        potx = int(valoresxy[0])
        poty = int(valoresxy[1])

        print(read)
    return





t1 = threading.Thread(target = ventana)
t2 = threading.Thread(target = Comunicacion)

t1.start()
t2.start()

t1.join()
t2.join()
