namespace Assignments.AssignmentThree
{
    internal class Assignment3
    {
        public void AssignmentThree()
        {
            TransportManager manager = new();

            manager.AddSchedule(new TransportSchedule { TransportType = "Bus", Route = "City A to City B", DepartureTime = DateTime.Parse("2023-10-25 08:00"), ArrivalTime = DateTime.Parse("2023-10-25 12:00"), Price = 25.00m, SeatsAvailable = 30 });
            manager.AddSchedule(new TransportSchedule { TransportType = "Flight", Route = "City A to City B", DepartureTime = DateTime.Parse("2023-10-25 09:00"), ArrivalTime = DateTime.Parse("2023-10-25 10:30"), Price = 150.00m, SeatsAvailable = 20 });
            manager.AddSchedule(new TransportSchedule { TransportType = "Bus", Route = "City B to City C", DepartureTime = DateTime.Parse("2023-10-25 14:00"), ArrivalTime = DateTime.Parse("2023-10-25 18:00"), Price = 30.00m, SeatsAvailable = 25 });
            manager.AddSchedule(new TransportSchedule { TransportType = "Flight", Route = "City B to City C", DepartureTime = DateTime.Parse("2023-10-25 16:00"), ArrivalTime = DateTime.Parse("2023-10-25 17:00"), Price = 120.00m, SeatsAvailable = 15 });

            Console.WriteLine("Search Results (TransportType = 'Flight'):");
            var searchResults = manager.SearchSchedules("Flight", "City A to City B", Convert.ToDateTime("2023-10-25 08:00"));
            foreach (var schedule in searchResults)
            {
                Console.WriteLine($"{schedule.TransportType} - {schedule.Route} - {schedule.DepartureTime} - {schedule.Price}");
            }

            Console.WriteLine("\nGrouped by Transport Type:");
            var groupedSchedules = manager.GroupSchedulesByTransportType();
            foreach (var group in groupedSchedules)
            {
                Console.WriteLine($"{group.Key}:");
                foreach (var schedule in group)
                {
                    Console.WriteLine($"  {schedule.Route} - {schedule.DepartureTime} - {schedule.Price}");
                }
            }

            Console.WriteLine("\nOrdered by Departure Time:");
            var orderedSchedules = manager.OrderSchedules("departuretime");
            foreach (var schedule in orderedSchedules)
            {
                Console.WriteLine($"{schedule.Route} - {schedule.DepartureTime} - {schedule.Price}");
            }

            Console.WriteLine("\nFiltered  Departure Time Range:");
            var filteredSchedules = manager.FilterSchedules(DateTime.Parse("2023-10-25 07:00"), DateTime.Parse("2023-10-25 17:00"));
            foreach (var schedule in filteredSchedules)
            {
                Console.WriteLine($"{schedule.Route} - {schedule.DepartureTime}");
            }

            var (totalSeats, averagePrice) = manager.AggregateSeatsAndPrice();
            Console.WriteLine($"\nTotal Seats Available: {totalSeats}");
            Console.WriteLine($"Average Price: {averagePrice}");

            Console.WriteLine("\nRoutes and Departure Times:");
            var routesAndTimes = manager.GetRoutesAndDepartureTimes();
            foreach (var (route, departureTime) in routesAndTimes)
            {
                Console.WriteLine($"{route} - Departure: {departureTime}");
            }
        }
    }
}
