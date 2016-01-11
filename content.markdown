Einstieg in Streams (mit und ohne Parallelisierung)
===================================================

Um aus einem Integer-Array einen Stream zu generieren, muss man über die
**Arrays** Klasse gehen

~~~ java
int[] zahlen = {1, 2, 3, 4};
IntStream is = Arrays.stream(zahlen);
~~~

Aufgabe 1 - IntStream
---------------------

Gegeben `int[] zahlen = {3, 5, 1, 3, 7, 29, 33, 49, 5, 1, 1, 2, 3};`

### Summe IntStream

~~~ java
IntStream is = Arrays.stream(zahlen);
System.out.Println(is.sum());
~~~

~~~ text
Output:
142
~~~

### Durschnitt IntStream

~~~ java
IntStream is = Arrays.stream(zahlen);
System.out.Println(is.average().getAsDouble());
~~~

~~~ text
Output:
10.923076923076923
~~~

### Maximum IntStream

~~~ java
IntStream is = Arrays.stream(zahlen);
System.out.Println(is.max());
~~~

~~~ text
Output:
49
~~~

### Histogramm IntStream

~~~ java
IntStream s = Arrays.stream(zahlen);
Map<Integer, Long> histogramm = 
    s.boxed().collect(Collectors.groupingBy(
        Integer::intValue, Collectors.counting()));
System.out.println(histogramm);
~~~

~~~ text
Output:
{49=1, 33=1, 1=3, 2=1, 3=3, 5=2, 7=1, 29=1}
~~~


### Ausgabe in der Form [3, 5, 3, ..., 2, 3]

~~~ java
IntStream s = Arrays.stream(zahlen);
String str = "["
			 + s.mapToObj(i -> String.valueOf(i)).collect(Collectors.joining(", "))
			 + "]";
System.out.println(str);
~~~

~~~ text
Output:
[3, 5, 1, 3, 7, 29, 33, 49, 5, 1, 1, 2, 3]
~~~

Aufgabe 2 - Stream<Integer>
---------------------------

### Summe 
~~~ java
List<Integer> zahlen = 
    Arrays.asList(new Integer[] { 3, 5, 1, 3, 7, 29, 33, 49, 5, 1, 1, 2, 3 });
System.out.println(zahlen.stream()
                  .collect(Collectors.summingInt(Integer::intValue)));
~~~

### Durchschnitt
~~~ java
List<Integer> zahlen = 
    Arrays.asList(new Integer[] { 3, 5, 1, 3, 7, 29, 33, 49, 5, 1, 1, 2, 3 });
System.out.println(zahlen.stream()
                  .collect(Collectors.averagingInt(Integer::intValue)));
~~~

### Maximum
~~~ java
List<Integer> zahlen =
    Arrays.asList(new Integer[] { 3, 5, 1, 3, 7, 29, 33, 49, 5, 1, 1, 2, 3 });
System.out.println(zahlen.stream()
                  .max(Integer::compareTo).get());
~~~

Achtung! `stream().max(...)` liefert ein `Optional<Integer>` weswegen man
eigentlich eine Fallunterscheidung wie im folgenden Beispiel machen müsste (aus
Einfachheitsgründen verzichte ich darauf)

~~~ java
List<Integer> zahlen =
    Arrays.asList(new Integer[] { 3, 5, 1, 3, 7, 29, 33, 49, 5, 1, 1, 2, 3 });
Optional<Integer> optInt = zahlen.stream().max(Integer::compareTo);
if(optInt.isPresent()) System.out.println(optInt.get());
~~~

### Histogramm

~~~ java
List<Integer> zahlen =
    Arrays.asList(new Integer[] { 3, 5, 1, 3, 7, 29, 33, 49, 5, 1, 1, 2, 3 });
System.out.println(zahlen.stream()
                  .collect(Collectors
                  .groupingBy(Integer::intValue, Collectors.counting())));
~~~

### Ausgabe

~~~ java
List<Integer> zahlen =
    Arrays.asList(new Integer[] { 3, 5, 1, 3, 7, 29, 33, 49, 5, 1, 1, 2, 3 });
System.out.println("[" 
                    + zahlen.stream()
                      .map(i -> i.toString())
                      .collect(Collectors.joining(", "))
                    + "]");
~~~

Parallelisieren mit Streams
===========================
Gegeben ist die folgende recht ineffiziente Primzahl-Testmethode für ganze
Zahlen >= 2. Diese Methode ist ein Prädikat für ganze Zahlen im Sinne von Java
8.

~~~ java
static boolean isPrime(int zahl) {
    int teiler = 2;
    while (zahl % teiler != 0)
        teiler++;
    if (zahl == teiler)
        return true;
    return false;
}
~~~

Aufgabe 1
---------
Geben Sie die Primzahlen im Bereich 1..1000 aus

~~~ java
System.out.println(IntStream
            .rangeClosed(1, 1000)
            .filter(MyIntStream::isPrime)
            .mapToObj(i -> String.valueOf(i))
            .collect(Collectors.joining(", ")));
~~~

Aufgabe 2
---------
Geben Sie die Primzahlen im Bereich 1..100000 aus. Nützen Sie alle Kerne Ihres
Rechners zur Berechnung!

~~~ java
System.out.println(IntStream
            .rangeClosed(1, 100000)
            .parallel()
            .filter(MyIntStream::isPrime)
            .mapToObj(i -> String.valueOf(i))
            .collect(Collectors.joining(", ")));
~~~

Aufgabe 3 (Optional)
--------------------
Wenn Ihnen die obige Methode zur Ermittlung von Primzahlen zu primitiv ist,
geben Sie eine effizientere Variante an.

Ein einfacher Spliterator
=========================
In einer der Aufgaben werden `Path`{.java}-Objekte (d. h. Objekte einer Klasse,
die die `Path`-Schnittstelle implementieren) von einem Erzeuger in eine
`BlockingQueue` gestellt.

Grundlagen
----------

Ein Spliterator ist ein **Interface** der Java API

~~~ java
public interface Spliterator<T> {
    public abstract boolean tryAdvance(Consumer<? super T>);
    public void forEachRemaining(Consumer<? super T>);
    public abstract Spliterator<T> trySplit();
    public abstract long estimateSize();
    public long getExactSizeIfKnown();
    public Comparator<? super T> getComparator();
}
~~~

Aufgabe 1: einfache Erzeuger-Verbraucher-Kopplung über einen Stream
-------------------------------------------------------------------
Eine `BlockingQueue` ist eine `Collection`. Damit erhalten wir einen Stream im
Sinne von Java 8 zum Durchlaufen der Resultate des o. a. Erzeugers. Verwenden
Sie diesen Stream in einem bzw. zwei Verbraucher(n) zum Auslesen aller
`Path`-Objekte.

Starten Sie einen Erzeuger und 1-2 Verbraucher. Das Hauptprogramm soll sich
erst beenden, wenn sich alle Erzeuger bzw. Verbraucher beendet haben.

Wie verhält sich ihr Programm?

* * *

Um nochmal zu verdeutlichen, dass Programm aus der vorherigen Aufgabe

~~~ java
public class Producer extends SimpleFileVisitor<Path> implements Runnable {
    private final BlockingQueue<Path> queue;
    private final int consumer;

    public Producer(BlockingQueue<Path> queue, int consumer)
    {
        this.queue = queue;
        this.consumer = consumer;
    }

    @Override
    public void run() {
        try {
            Path path = Paths.get("/home/gunibert/development");
            Files.walkFileTree(path, this);
            for(int i = 0; i < consumer; ++i) {
            	Path poisonPill = Paths.get("wearedone");
            	queue.put(poisonPill);
            }
        } catch(IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }

    @Override
    public FileVisitResult visitFile(
        Path file, BasicFileAttributes arg1) throws IOException {

        if(file.toString().matches(".*\\.(java|cpp|h)")) {
            try {
                queue.put(file);
            } catch(Exception e){
                e.printStackTrace();
            }
        }

        return FileVisitResult.CONTINUE;
    }
}
~~~

~~~ java
public class Consumer implements Runnable {
    private BlockingQueue<Path> queue;
    private boolean run = true;

    public Consumer(BlockingQueue<Path> queue) {
        this.queue = queue;
    }

    @Override
    public void run() {
        while(run){
        	
            try {
                Path p = (Path)queue.take();
                handlePath(p);
            } catch(Exception e){
                e.printStackTrace();
            }
        }
    }

	private void handlePath(Path p) {
		if(p.toString().equals("wearedone")) {
			run = false;
		} else {
			System.out.printf("File: %s\n", p.getFileName());
		}
	}
}
~~~

~~~ java
public static void main(String[] args) {
    BlockingQueue<Path> queue = new LinkedBlockingQueue<Path>();
    Producer p = new Producer(queue, 1);
    Consumer c = new Consumer(queue);
    
    new Thread(c).start();
    new Thread(p).start();
}
~~~

Anstelle des `Consumers` sollen wir hier einen Stream zum Auslesen der
`Path`-Objekte nutzen.

Ich hab das jetzt einmal mit diesem Codeschnippsel getestet und bin nicht
sicher, ob ich damit das gewünschte Ergebnis bekomme.

~~~ java
queue.stream().map(path -> path.toString()).forEach(System.out::println);
~~~

Die Krux an der Sache ist, dass man zum Zeitpunkt t als Stream lediglich den
Inhalt bekommt, der da ist. Nachdem dieser ausgelesen wurde, beendet sich das
Programm (was nicht der eigentliche Nutzen sein sollte). 

Aufgabe 2: ein selbst erstellter Spliterator
--------------------------------------------
Geben Sie einen `Spliterator` für die o. a. `BlockingQueue` an. Sie können
hierzu die Methode `stream` der Klasse `java.util.stream.StreamSupport`
benützen. Stellen Sie sicher, dass alle vom Erzeuger gelieferten Objekte auch
vom Verbraucher gelesen werden.

Aufgaben aus Java Magazine von Oracle
=====================================

~~~ java
import java.util.Random;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class JavaMagazine2014Sept {
    static final int MAXSEEDVALUE = 200_000;
    static final int SEEDVALUE = new Random().nextInt(MAXSEEDVALUE);
    static final int COUNT = 10;

    public static void main(String[] args) {
        System.out.println(IntStream.rangeClosed(SEEDVALUE+1,MAXSEEDVALUE)
        .parallel()
        .filter(i -> IntStream. range (2, i)
        .filter(j-> i%j == 0)
        .count() == 0)
        .limit(COUNT)
        .mapToObj(String::valueOf )
        .collect(Collectors.joining("")));
    }
}
~~~

This program finds the `COUNT` number of prime numbers that are greater than
some random starting value. It runs slowly because its not making effective use
of the Stream API. What change could be made that would result in a
considerable speedup?

1. Replace the lambda expression `(j -> i % j == 0)` by an anonymous class
   implementing the `IntPredicate` interface
2. Move the `limit()` function before the outer `filter()`
3. Use `noneMatch()` instead of the inner `filter()`
4. Replace both `filter()` functions using the iteration of the Java
   Collections Framework.

Desktop-Suche
=============

Gegeben ist ein GUI Rahmenprogramm (siehe con-ws14-blatt07.zip im eLearning)

Aufgabe 1
---------

Auf Drückn der `Start`-Schaltfläche soll eine nebenläufige Suche gestartet
werden. Teilergebnisse und das Endergebnis der Suche sollen angezeigt werden
(im Hauptfenster). Benützen Sie dazu eine Ihrer Lösungen der Aufgabe 4.

Aufgabe 2
---------

Nach dem Drücken des `Stop`-Schalters sollen alle gestarteten Aktivitäten so
bald wie möglich beendet werden. Die laufende GUI soll nicht abgebrochen
werden. `System.exit()` löst das Problem nicht.

Optimistisches Sperren
======================

Aufgabe 1 - Sieht leicht aus, ist aber nicht ganz leicht
--------------------------------------------------------

Versuchen Sie, einen Zähler in einem System mit Nebenläufigkeit für ganze
Zahlen zu implementieren. `next()` soll beginnend ab 0 fortlaufend ganze Zahlen
liefern. *Die Performance sollte besser sein, als bei einer Lösung mit einer
`synchronized next()`-Funktion.*

~~~ java
class Counter {
    private ... int counter;
    public int next() { return counter++; } // Liefern und schalten
}
~~~

\begin{important}
Prinzipiell wird man eine Lösung bei den sog. optimistischen Sperren suchen.
\textbf{Aber}: man kann wohl nur dann Lösungen mit kürzeren Antwortzeiten
finden, wenn man die Phasen der Sperrung reduziert. Einen möglichen Ansatz
zeigt D. Lea mit seinem Programm `Spinlock` (siehe unten).
\end{important}

Optimistische Updates: [Lea99, 2.4.4.2]
---------------------------------------
Ein optimistisches Update hat 3 Phasen

1. Innerhalb einer Sperre: Kopieren des aktuellen Zustands
2. Außerhalb der Sperre: Kopie ändern
3. Innerhalb einer Sperre: Zurückschreiben, aber nur, falls sich der Zustand
   nicht geändert hat

Optimistische Update-Techniken Sperren den Zugriff auf Objekte nur kurz,
insbesondere bei Multicore-Prozessoren.

~~~ java
class Optimistic { // Generic code sketch
    private State state;

    private synchronized State getState() {
        return state;
    }

    private synchronized boolean commit(State assumed, State next) {
        if (state == assumed) {
            state = next;
            return true;
        } else {
            return false;
        }
    }
}
~~~

### Was tun, wenn der commit nicht klappt?
Ansatz: wir probieren es solange, bis es klappt. Dazu wollen wir die Sperre
möglichst kurz halten, wie im folgenden Beispiel für einen Spinlock aus [Lea99,
3.2.6.5]. Wenn Sie das Beispiel selbst implementieren, werden Sie sehen, dass
die Laufzeiten steigen, wenn man nach den Fehlschlägen beim `commit` sofort
wieder probiert, ob das `commit` erfolgreich ist. Die Schwierigkeit besteht
darin, die *richtigen* Pausen für die Wiederholung zu finden.

### Aktives Warten: Busy Wait nach [Lea99, 3.2.6.5]

\begin{important}
Busy Wait ist nur für extreme Sonderfälle sinnvoll. Meist funktioniert die
einfache Lösung mit \mintinline{java}{wait()} und
\mintinline{java}{notifyAll()} besser. Zuverlässiger ist sie in jedem Fall.
\end{important}

Das folgende Listing zeigt die einfachste Form eines sog. "Spinlock".

~~~ java
protected void busyWaitUntilCond() {
    while(!busy) {
        Thread.yield();
    }
}
~~~

1. Ein Spinlock kann beliebig viel CPU-Zeit verbrauchen
2. \mintinline{java}{yield} ist nur ein Hinweis an die JVM, es muss kein
anderer Thread aktiviert werden
3. Einzig sinnvoller Anwendungsfalls: extrem "kurze" kritische Abschnitte

~~~ java
class SpinLock { // Avoid needing to use this
    private volatile boolean busy = false;

    synchronized void release() {
        busy = false;
    }

    void acquire() throws InterruptedException {
        int itersBeforeYield = 100; // 100 is arbitrary
        int itersBeforeSleep = 200; // 200 is arbitrary
        long sleepTime = 1; // 1msec is arbitrary
        int iters = 0;
        for(;;) {
            if(!busy) { // test-and-test-and-set
                synchronized(this) {
                    if(!busy) {
                        busy = true;
                        return;
                    }
                }
            }

            if(iters < itersBeforeYield) { // spin phase
                ++iters;
            } else if(iters < itersBeforeSleep) { // yield phase
                ++iters;
                Thread.yield();
            } else { // back-off phase
                Thread.sleep(sleepTime);
                sleepTime = 3 * sleepTime / 2 + 1; // 50 percent is arbitrary
            }
        }
    }
}
~~~
