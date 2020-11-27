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
    
    pot0 = "0"
    pot1 = "0"
    pot2 = "0"
    
    raiz = Tk()
    raiz.title("Cara animada")
    raiz.geometry("900x900")

    raiz.config(bg ="grey")
    
    var = StringVar()
    var.set('hello')
    
    var2 = StringVar()
    var2.set('hello')

    var3 = StringVar()
    var3.set('hello')


    label1 = Label(raiz, textvariable = var)
    label1.pack()
    label2 = Label(raiz, textvariable = var2)
    label2.pack()
    label3 = Label(raiz, textvariable = var3)
    label3.pack()
    

    
    
    while True:
        var.set("Valor de potenciometro que controla la boca  "+pot0)
        var2.set("Valor de potenciometro que controla la ceja 1  "+pot1)
        var3.set("Valor de potenciometro que controla la ceja 2  "+pot2)
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
        try:
            pic.readline()
            read = pic.readline().decode('ascii')
            valoresPOT = read.split(",")
        except:
            print("hola")
        global pot0
        global pot1
        global pot2
        
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
