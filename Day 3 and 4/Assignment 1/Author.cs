namespace Assignments.AssignmentOne
{
    public class Author
    {
        public int AuthorID { get; set; }
        public string AuthorName { get; set; }

        public override string ToString()
        {
            return $"AuthorID: {AuthorID}\t AuthorName: {AuthorName}";
        }
    }
}
